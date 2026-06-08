-- Projet BI - Global YouTube Statistics Data Warehouse
-- Module Entrepot de Donnees - 2LGL 2025/2026
-- Schema en etoile : 1 table de faits + 4 dimensions

DROP TABLE IF EXISTS FACT_PERFORMANCE;
DROP TABLE IF EXISTS DIM_CHAINE;
DROP TABLE IF EXISTS DIM_DATE;
DROP TABLE IF EXISTS DIM_GEO;
DROP TABLE IF EXISTS DIM_CATEGORIE;

CREATE TABLE DIM_CHAINE (
    id_chaine   INTEGER PRIMARY KEY,
    youtuber    TEXT NOT NULL,
    titre       TEXT NOT NULL,
    type_chaine TEXT NOT NULL
);

CREATE TABLE DIM_DATE (
    id_date INTEGER PRIMARY KEY,
    annee   INTEGER NOT NULL,
    mois    TEXT NOT NULL,
    jour    INTEGER NOT NULL
);

CREATE TABLE DIM_GEO (
    id_geo    INTEGER PRIMARY KEY,
    pays      TEXT NOT NULL,
    code_pays TEXT NOT NULL
);

CREATE TABLE DIM_CATEGORIE (
    id_categorie INTEGER PRIMARY KEY,
    categorie    TEXT NOT NULL
);

CREATE TABLE FACT_PERFORMANCE (
    id_fait            INTEGER PRIMARY KEY,
    id_chaine          INTEGER NOT NULL,
    id_date            INTEGER NOT NULL,
    id_geo             INTEGER NOT NULL,
    id_categorie       INTEGER NOT NULL,
    abonnes            INTEGER NOT NULL DEFAULT 0,
    vues               INTEGER NOT NULL DEFAULT 0,
    uploads            INTEGER NOT NULL DEFAULT 0,
    revenu_mensuel_max REAL NOT NULL DEFAULT 0,
    revenu_annuel_max  REAL NOT NULL DEFAULT 0,
    FOREIGN KEY (id_chaine)    REFERENCES DIM_CHAINE(id_chaine),
    FOREIGN KEY (id_date)      REFERENCES DIM_DATE(id_date),
    FOREIGN KEY (id_geo)       REFERENCES DIM_GEO(id_geo),
    FOREIGN KEY (id_categorie) REFERENCES DIM_CATEGORIE(id_categorie)
);

-- Requete 1 : top 5 chaines par abonnes
SELECT ch.youtuber, g.pays, f.abonnes
FROM FACT_PERFORMANCE f
JOIN DIM_CHAINE ch ON f.id_chaine = ch.id_chaine
JOIN DIM_GEO g ON f.id_geo = g.id_geo
ORDER BY f.abonnes DESC
LIMIT 5;

-- Requete 2 : abonnes par categorie
SELECT c.categorie, SUM(f.abonnes) AS total_abonnes, COUNT(*) AS nb_chaines
FROM FACT_PERFORMANCE f
JOIN DIM_CATEGORIE c ON f.id_categorie = c.id_categorie
GROUP BY c.categorie
ORDER BY total_abonnes DESC
LIMIT 10;

-- Requete 3 : abonnes par pays
SELECT g.pays, COUNT(*) AS nb_chaines, SUM(f.abonnes) AS total_abonnes
FROM FACT_PERFORMANCE f
JOIN DIM_GEO g ON f.id_geo = g.id_geo
GROUP BY g.pays
ORDER BY total_abonnes DESC
LIMIT 5;

-- Requete 4 : evolution par annee
SELECT d.annee, COUNT(*) AS nb_chaines, SUM(f.abonnes) AS total_abonnes
FROM FACT_PERFORMANCE f
JOIN DIM_DATE d ON f.id_date = d.id_date
GROUP BY d.annee
ORDER BY d.annee;

-- Requete 5 : performance par type de chaine
SELECT ch.type_chaine, AVG(f.abonnes) AS abonnes_moy, AVG(f.revenu_annuel_max) AS revenu_moy
FROM FACT_PERFORMANCE f
JOIN DIM_CHAINE ch ON f.id_chaine = ch.id_chaine
GROUP BY ch.type_chaine
ORDER BY abonnes_moy DESC;

-- Verification : nombre de lignes par table
SELECT 'DIM_CHAINE' AS table_name, COUNT(*) AS nb FROM DIM_CHAINE
UNION ALL SELECT 'DIM_DATE', COUNT(*) FROM DIM_DATE
UNION ALL SELECT 'DIM_GEO', COUNT(*) FROM DIM_GEO
UNION ALL SELECT 'DIM_CATEGORIE', COUNT(*) FROM DIM_CATEGORIE
UNION ALL SELECT 'FACT_PERFORMANCE', COUNT(*) FROM FACT_PERFORMANCE;
