/* Author: Cristian Gomez - 201801480 */
-- Borrado y creado de la base de datos propuesta */

USE proyecto2;

-- ==================================================================================================
-- Deletion of the entire model
-- ==================================================================================================
-- DROP TABLE RESULT_DETAIL;
DROP TABLE RESULT;
DROP TABLE PARTY;
DROP TABLE ELECTION;
DROP TABLE SEX;
DROP TABLE RACE;
DROP TABLE TOWN;
DROP TABLE DEPTO;
DROP TABLE REGION;
DROP TABLE COUNTRY;

-- ==================================================================================================
-- Creation of the SEX table 
-- ==================================================================================================
CREATE TABLE SEX(
    sex_id      INT NOT NULL AUTO_INCREMENT,
    name        VARCHAR(40),
    PRIMARY KEY(sex_id)
);

-- ALTER TABLE SEX 
--     ADD CONSTRAINT sex_pk PRIMARY KEY(sex_id);

-- ==================================================================================================
-- Creation of the RACE table 
-- ==================================================================================================
CREATE TABLE RACE (
    race_id     INT NOT NULL AUTO_INCREMENT,
    name        VARCHAR(50),
    PRIMARY KEY(race_id)
); 

-- ALTER TABLE RACE
--     ADD CONSTRAINT race_pk PRIMARY KEY(race_id);

-- ==================================================================================================
-- Creation of the COUNTRY table 
-- ==================================================================================================
CREATE TABLE COUNTRY(
    country_id      INT NOT NULL AUTO_INCREMENT,
    name            VARCHAR(80),
    PRIMARY KEY(country_id)
);

-- ALTER TABLE COUNTRY
--     ADD CONSTRAINT country_pk PRIMARY KEY(country_id);

-- ==================================================================================================
-- Creation of the REGION table 
-- ==================================================================================================
CREATE TABLE REGION(
    region_id      INT NOT NULL AUTO_INCREMENT,
    name           VARCHAR(80) NOT NULL,
    country_id     INT NOT NULL,
    PRIMARY KEY(region_id)
);

ALTER TABLE REGION
    ADD CONSTRAINT region_country_fk FOREIGN KEY(country_id)
        REFERENCES COUNTRY(country_id);

-- ==================================================================================================
-- Creation of the DEPTO table 
-- ==================================================================================================
CREATE TABLE DEPTO(
    depto_id      INT NOT NULL AUTO_INCREMENT,
    name          VARCHAR(80) NOT NULL,
    region_id     INT NOT NULL,
    PRIMARY KEY(depto_id)
);

ALTER TABLE DEPTO
    ADD CONSTRAINT depto_region_fk FOREIGN KEY(region_id)
        REFERENCES REGION(region_id);


-- ==================================================================================================
-- Creation of the TOWN table 
-- ==================================================================================================
CREATE TABLE TOWN(
    town_id      INT NOT NULL AUTO_INCREMENT,
    name         VARCHAR(80) NOT NULL,
    depto_id     INT NOT NULL,
    PRIMARY KEY(town_id)
);

ALTER TABLE TOWN
    ADD CONSTRAINT town_depto_fk FOREIGN KEY(depto_id)
        REFERENCES DEPTO(depto_id);


-- ==================================================================================================
-- Creation of the ELECTION table 
-- ==================================================================================================
CREATE TABLE ELECTION(
    election_id      INT NOT NULL AUTO_INCREMENT,
    name             VARCHAR(80) NOT NULL,
    year             INT NOT NULL,
    PRIMARY KEY(election_id)
);

-- ==================================================================================================
-- Creation of the PARTY table 
-- ==================================================================================================
CREATE TABLE PARTY(
    party_id          INT NOT NULL AUTO_INCREMENT,
    party             VARCHAR(80) NOT NULL,
    name              VARCHAR(100) NOT NULL,
    -- election_id       INT NOT NULL,
    PRIMARY KEY(party_id)
);

-- ==================================================================================================
-- Creation of the SEX table 
-- ==================================================================================================

CREATE TABLE RESULT(
    result_id       INT NOT NULL AUTO_INCREMENT,
    illiterate      INT NOT NULL,
    alphabet        INT NOT NULL,
    primary_level   INT NOT NULL,
    medium_level    INT NOT NULL,
    academic        INT NOT NULL,
    town_id         INT NOT NULL,
	election_id     INT NOT NULL,
    party_id 		INT NOT NULL,
    sex_id          INT NOT NULL, 
    race_id         INT NOT NULL,
    PRIMARY KEY(result_id)
);


ALTER TABLE RESULT
    ADD CONSTRAINT result_sex_fk FOREIGN KEY(sex_id)
        REFERENCES SEX(sex_id);

ALTER TABLE RESULT
    ADD CONSTRAINT result_race_fk FOREIGN KEY(race_id)
        REFERENCES RACE(race_id);
        
ALTER TABLE RESULT
    ADD CONSTRAINT result_election_fk FOREIGN KEY(election_id)
        REFERENCES ELECTION(election_id);
        
ALTER TABLE RESULT
    ADD CONSTRAINT result_party_fk FOREIGN KEY(party_id)
        REFERENCES PARTY(party_id);

ALTER TABLE RESULT
    ADD CONSTRAINT result_town_fk FOREIGN KEY(town_id)
        REFERENCES TOWN(town_id);


-- ==================================================================================================
-- Creation of the SEX table 
-- ==================================================================================================

-- CREATE TABLE RESULT_DETAIL(
--     result_detail_id       INT NOT NULL AUTO_INCREMENT,
--     result_id              INT NOT NULL,
--     election_id            INT NOT NULL,
--     town_id                INT NOT NULL,
--     PRIMARY KEY(result_detail_id)
-- );

-- -- ALTER TABLE RESULT_DETAIL
-- --     ADD CONSTRAINT result_detail_pk PRIMARY KEY(result_detail_id);


-- ALTER TABLE RESULT_DETAIL
--     ADD CONSTRAINT result_detail_result_fk FOREIGN KEY(result_id)
--         REFERENCES RESULT(result_id);

-- ALTER TABLE RESULT_DETAIL
--     ADD CONSTRAINT result_detail_election_fk FOREIGN KEY(election_id)
--         REFERENCES ELECTION(election_id);



-- ALTER TABLE RESULT_DETAIL
--     ADD CONSTRAINT result_detail_town_fk FOREIGN KEY(town_id)
--         REFERENCES TOWN(town_id);



