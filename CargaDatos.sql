CREATE database proyecto2;
USE proyecto2;

SET GLOBAL local_infile=1;
SHOW GLOBAL VARIABLES LIKE 'local_infile';
LOAD DATA LOCAL INFILE 'C:\\Users\\crisg\\Documents\\GitHub\\bd1-proyecto2-201801480\\data.csv' 
INTO TABLE proyecto2.TEMPORARY COLUMNS TERMINATED BY ','
-- LINES TERMINATED BY '\r\n' -- LINUX  '\n' 
IGNORE 1 LINES (NOMBRE_ELECCION,AÑO_ELECCION,PAIS,REGION,DEPTO,MUNICIPIO,PARTIDO,NOMBRE_PARTIDO,SEXO,RAZA,ANALFABETOS,ALFABETOS,SEXO,RAZA,PRIMARIA,NIVEL_MEDIO,UNIVERSITARIOS);

-- DROP TABLE TEMPORARY;

CREATE TABLE TEMPORARY (
    NOMBRE_ELECCION     VARCHAR(100),
    AÑO_ELECCION        VARCHAR(100),
    PAIS                VARCHAR(100),
    REGION              VARCHAR(100),
    DEPTO               VARCHAR(100),
    MUNICIPIO           VARCHAR(100),
    PARTIDO             VARCHAR(100),
    NOMBRE_PARTIDO      VARCHAR(100),
    SEXO                VARCHAR(100),
    RAZA                VARCHAR(100),
    ANALFABETOS         VARCHAR(100),
    ALFABETOS           VARCHAR(100),
    PRIMARIA            VARCHAR(100),
    NIVEL_MEDIO         VARCHAR(100),
    UNIVERSITARIOS      VARCHAR(100)
);

SELECT COUNT(*) FROM TEMPORARY;


-- ==================================================================================================
-- Inserting data to the SEX table 
-- ==================================================================================================

INSERT SEX (name) 
    SELECT DISTINCT sexo FROM TEMPORARY;

-- ==================================================================================================
-- Inserting data to the RACE table 
-- ==================================================================================================
INSERT RACE (name)
    SELECT DISTINCT raza FROM TEMPORARY;

-- ==================================================================================================
-- Inserting data to the COUNTRY table 
-- ==================================================================================================
INSERT COUNTRY (name)
    SELECT DISTINCT pais FROM TEMPORARY;

-- ==================================================================================================
-- Inserting data to the REGION table 
-- ==================================================================================================

INSERT REGION (name, country_id)
    SELECT DISTINCT region, c.country_id
        FROM TEMPORARY
            INNER JOIN COUNTRY c ON c.name = pais;

-- ==================================================================================================
-- Inserting data to the DEPTO table 
-- ==================================================================================================
INSERT DEPTO (name, region_id)
    SELECT DISTINCT depto, r.region_id
        FROM TEMPORARY
			INNER JOIN COUNTRY c ON c.name = pais
            INNER JOIN REGION r ON r.name = region AND r.country_id = c.country_id;

-- ==================================================================================================
-- Inserting data to the TOWN table 
-- ==================================================================================================
INSERT TOWN (name, depto_id)
    SELECT DISTINCT municipio, d.depto_id
        FROM TEMPORARY
			INNER JOIN COUNTRY c ON c.name = pais
            INNER JOIN REGION r ON r.name = region AND r.country_id = c.country_id
            INNER JOIN DEPTO d ON d.name = depto AND d.region_id = r.region_id;

-- ==================================================================================================
-- Inserting data to the ELECTION table 
-- ==================================================================================================
INSERT INTO ELECTION(name, year)
    SELECT DISTINCT nombre_eleccion, (año_eleccion * 1) AS year FROM TEMPORARY;

-- ==================================================================================================
-- Inserting data to the PARTY table 
-- ==================================================================================================
INSERT INTO PARTY(party, name, election_id)
	SELECT DISTINCT partido, nombre_partido, e.election_id
		FROM TEMPORARY
			INNER JOIN ELECTION e ON e.name = nombre_eleccion AND e.year = año_eleccion;

-- ==================================================================================================
-- Inserting data to the RESULT table 
-- ==================================================================================================
INSERT INTO RESULT (
    illiterate,   
    alphabet,     
    primary_level,
    medium_level,
    academic,     
    town_id,       
	-- election_id,
    party_id,
    sex_id,       
    race_id      
    )
  SELECT DISTINCT te.analfabetos, 
                    te.alfabetos, 
                    te.primaria, 
                    te.nivel_medio, 
                    te.universitarios, 
                    town_id,       
                    -- election_id,  
                    party_id,
                    s.sex_id,
                    r.race_id 
        FROM TEMPORARY te
            INNER JOIN SEX s ON s.name = sexo
            INNER JOIN RACE r ON r.name = raza
            INNER JOIN ELECTION e ON e.name = nombre_eleccion AND e.year = año_eleccion
			INNER JOIN PARTY p ON p.name = nombre_partido AND p.party = partido
            INNER JOIN COUNTRY c ON c.name = pais
            INNER JOIN REGION re ON re.name = region AND re.country_id = c.country_id
            INNER JOIN DEPTO d ON d.name = depto AND d.region_id = re.region_id
            INNER JOIN TOWN t ON t.name = municipio AND t.depto_id = d.depto_id;






-- ==================================================================================================
-- Inserting data to the RESULT_DETAIL table 
-- ==================================================================================================

-- INSERT INTO RESULT_DETAIL (
--         result_id,       
--         election_id,     
--         town_id          
--     )
--     SELECT DISTINCT rl.result_id,
--                     e.election_id,
--                     t.town_id 
--         FROM TEMPORARY
--             INNER JOIN RESULT rl ON rl.illiterate = analfabetos AND rl.alphabet = alfabetos AND rl.primary_level = primaria
--             INNER JOIN ELECTION e ON e.name = nombre_eleccion AND e.year = año_eleccion
--             INNER JOIN COUNTRY c ON c.name = pais
--             INNER JOIN REGION r ON r.name = region AND r.country_id = c.country_id
--             INNER JOIN DEPTO d ON d.name = depto AND d.region_id = r.region_id
--             INNER JOIN TOWN t ON t.name = municipio AND t.depto_id = d.depto_id;
