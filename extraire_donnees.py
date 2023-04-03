#! /usr/bin/python3
import argparse
import sqlalchemy
from sqlalchemy.sql import text
import getpass
def ouvrir_connexion(user,passwd,host,database):
    """
    ouverture d'une connexion MySQL
    paramètres:
       user     (str) le login MySQL de l'utilsateur
       passwd   (str) le mot de passe MySQL de l'utilisateur
       host     (str) le nom ou l'adresse IP de la machine hébergeant le serveur MySQL
       database (str) le nom de la base de données à utiliser
    résultat: l'objet qui gère le connection MySQL si tout s'est bien passé
    """
    try:
        #creation de l'objet gérant les interactions avec le serveur de BD
        engine=sqlalchemy.create_engine('mysql+mysqlconnector://'+user+':'+passwd+'@'+host+'/'+database)
        #creation de la connexion
        cnx = engine.connect()
    except Exception as err:
        print(err)
        raise err
    print("connexion réussie")
    return cnx

def remplacer_parametres(texte,parametres):
    ind=0
    res=''
    for param in parametres:
        ind_suiv=texte.find('?',ind)
        if ind_suiv==-1:
            return res+texte[ind:]
        try:
            _=float(param)
            quote=""
        except:
            quote="'"

        res+=texte[ind:ind_suiv]+quote+param+quote
        ind=ind_suiv+1
    return res+texte[ind:]



def requete_to_str(connexion,texte,parametres=[],sep=';'):
    texte=remplacer_parametres(texte,parametres)
    print(texte)
    resultat=connexion.execute(texte)
    res=''
    pref=''
    for nom_col in resultat.keys():
        res+=pref+nom_col
        pref=sep
    res+='\n'
    for ligne in resultat:
        pref=""
        for colonne in ligne:
            res+=pref+str(colonne)
            pref=sep
        res+='\n'
    return res
    
  

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--login", dest="login", help="login sur la base de données", type=str, default='pasdelogin')
    parser.add_argument("--serveur", dest="serveur", help="serveur de base de données", type=str, default='servinfo-mariadb')
    parser.add_argument("--bd", dest="base_de_donnees", help="nom de la base de données", type=str, default='LEGO')
    parser.add_argument("--requete", dest="requete", help="requete à exécuter", type=str)
    parser.add_argument("--fic_requete", dest="fic_req", help="fichier contenant la requête", type=str, default='requete.sql')
    parser.add_argument("--fic_res", dest="fic_res", help="fichier resultat", type=str, default='result.csv')
    parser.add_argument("--parametres", type=str, nargs='*', help='valeurs des paramètres de la requête', default=[])
    args = parser.parse_args()
    passwd = getpass.getpass("mot de passe SQL:")

    if args.requete is None:
        try:
            with open(args.fic_req) as fic:
                requete=fic.read()
        except Exception as e:
            print("La lecture du fichier",args.fic_req,"a échoué")
            print(e)
            exit(0)
    else:
        requete=args.requete

    try:
        cnx=ouvrir_connexion(args.login, passwd, args.serveur, args.base_de_donnees)
    except Exception as e:
        print("La connection a échoué avec l'erreur suivante:", e)
        exit(0)
    try:
        res=requete_to_str(cnx,requete,args.parametres)
    except Exception as e:
        print("L'exécution de la requête a échoué avec l'erreur suivant",e)
        exit(0)

    try:
        with open(args.fic_res,"w") as fic:
            fic.write(res)
    except Exception as e:
        print("L'écriture du fichier",args.fic_res,"a échoué")
        print(e)
        exit(0)
    cnx.close()
