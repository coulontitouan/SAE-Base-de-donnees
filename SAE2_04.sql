-- TP 2_04
-- Nom: Coulon , Prenom: Titouan

-- +------------------+--
-- * Question 1 :     --
-- +------------------+--
-- Ecrire une requête qui renvoie les informations suivantes:
--  La liste des objets vendus par ght1ordi au mois de février 2023

-- Voici le début de ce que vous devez obtenir.
-- ATTENTION à l'ordre des colonnes et leur nom!
-- +----------+----------------------+
-- | pseudout | nomob                |
-- +----------+----------------------+
-- | etc...
-- = Reponse question 1.

select pseudoUt,nomOb from UTILISATEUR natural join OBJET natural join VENTE natural join STATUT
where YEAR(finVe) = 2023 and MONTH(finVe) = 02 and pseudoUt = "ght1ordi" and idSt='4';

-- +------------------+--
-- * Question 2 :     --
-- +------------------+--
-- Ecrire une requête qui renvoie les informations suivantes:
--  La liste des utilisateurs qui ont enchérit sur un objet qu’ils ont eux même mis en vente

-- Voici le début de ce que vous devez obtenir.
-- ATTENTION à l'ordre des colonnes et leur nom!
-- +-----------+
-- | pseudout  |
-- +-----------+
-- | etc...
-- = Reponse question 2.

select distinct pseudoUt from UTILISATEUR natural join OBJET natural join VENTE natural join ENCHERIR;

-- +------------------+--
-- * Question 3 :     --
-- +------------------+--
-- Ecrire une requête qui renvoie les informations suivantes:
--  La liste des utilisateurs qui ont mis en vente des objets mais uniquement des meubles

-- Voici le début de ce que vous devez obtenir.
-- ATTENTION à l'ordre des colonnes et leur nom!
-- +-------------+
-- | pseudout    |
-- +-------------+
-- | etc...
-- = Reponse question 3.

select distinct pseudout
from UTILISATEUR
where idut not in (
select idut from UTILISATEUR natural join OBJET natural join CATEGORIE where nomCat!='Meuble')
and idut in (
select idut from UTILISATEUR natural join OBJET natural join CATEGORIE where nomCat='Meuble');
   
-- +------------------+--
-- * Question 4 :     --
-- +------------------+--
-- Ecrire une requête qui renvoie les informations suivantes:
--  La liste des objets qui ont généré plus de 15 enchères en 2022

-- Voici le début de ce que vous devez obtenir.
-- ATTENTION à l'ordre des colonnes et leur nom!
-- +------+----------------------+
-- | idob | nomob                |
-- +------+----------------------+
-- | etc...
-- = Reponse question 4.

select idob,nomob
from OBJET natural join VENTE natural join ENCHERIR 
where YEAR(dateheure)=2022
having count(montant)>15;

-- +------------------+--
-- * Question 5 :     --
-- +------------------+--
-- Ecrire une requête qui renvoie les informations suivantes:
--  Ici NE CREEZ PAS la vue PRIXVENTE mais indiquer simplement la requête qui lui est associée. 
-- C'est à dire la requête permettant d'obtenir pour chaque vente validée, l'identifiant de la vente l'identiant de l'acheteur et le prix de la vente.

-- Voici le début de ce que vous devez obtenir.
-- ATTENTION à l'ordre des colonnes et leur nom!
-- +------+------------+----------+
-- | idve | idacheteur | montant  |
-- +------+------------+----------+
-- | etc...
-- = Reponse question 5.

select idve,iduT as idacheteur, montant
from UTILISATEUR natural join ENCHERIR natural join STATUT
where idSt=4 and montant in (
select max(montant) from ENCHERIR ENCHERIR2
where ENCHERIR.idve=ENCHERIR2.idve)
group by idve;

-- +------------------+--
-- * Question 6 :     --
-- +------------------+--
-- Ecrire une requête qui renvoie les informations suivantes:
--  Le chiffre d’affaire par mois de la plateforme (en utilisant la vue PRIXVENTE)

-- Voici le début de ce que vous devez obtenir.
-- ATTENTION à l'ordre des colonnes et leur nom!
-- +------+-------+-----------+
-- | mois | annee | ca        |
-- +------+-------+-----------+
-- | etc...
-- = Reponse question 6.

create or replace view PRIXVENTE as 
select idve,iduT as acheteur,montant
from UTILISATEUR natural join ENCHERIR natural join STATUT
where idSt=4 and montant in (
select max(montant) from ENCHERIR ENCHERIR2
where ENCHERIR.idve=ENCHERIR2.idve)
group by idve;

select MONTH(dateheure) as mois, YEAR(dateheure) as annee, sum(montant)*5/100 as ca
from PRIXVENTE natural join ENCHERIR
group by annee,mois;

-- +------------------+--
-- * Question 7 :     --
-- +------------------+--
-- Ecrire une requête qui renvoie les informations suivantes:
--  Les informations du ou des utilisateurs qui ont mis le plus d’objets en vente

-- Voici le début de ce que vous devez obtenir.
-- ATTENTION à l'ordre des colonnes et leur nom!
-- +------+----------+------+
-- | idut | pseudout | nbob |
-- +------+----------+------+
-- | etc...
-- = Reponse question 7.

create or replace view NombreDObjetsEnVente as 
select iduT,pseudout, count(idOb) as nbob
from UTILISATEUR natural join OBJET
group by idUt;

select * 
from NombreDObjetsEnVente
where nbob in (
select max(nbob)
from NombreDObjetsEnVente);

-- +------------------+--
-- * Question 8 :     --
-- +------------------+--
-- Ecrire une requête qui renvoie les informations suivantes:
--  le camembert

-- Voici le début de ce que vous devez obtenir.
-- ATTENTION à l'ordre des colonnes et leur nom!
-- +-------+-------------------+-----------+
-- | idcat | nomcat            | nb_objets |
-- +-------+-------------------+-----------+
-- | etc...
-- = Reponse question 8.

select idcat, nomcat, count(idob) as nb_objets
from OBJET natural join CATEGORIE natural join VENTE
where YEAR(finVe) = 2022
group by idCat,nomCat;

-- +------------------+--
-- * Question 9 :     --
-- +------------------+--
-- Ecrire une requête qui renvoie les informations suivantes:
--  Le top des vendeurs

-- Voici le début de ce que vous devez obtenir.
-- ATTENTION à l'ordre des colonnes et leur nom!
-- +------+-------------+----------+
-- | idut | pseudout    | total    |
-- +------+-------------+----------+
-- | etc...
-- = Reponse question 9.

select pseudout,sum(montant) as total 
from UTILISATEUR natural join PRIXVENTE natural join ENCHERIR natural join VENTE
where YEAR(dateheure)=2023 and MONTH(dateheure)=1
group by idut 
order by total DESC
limit 10;