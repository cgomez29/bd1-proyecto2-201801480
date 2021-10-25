-- https://leaf-equinox-58d.notion.site/Resultado-de-reportes-49a2c15fcc2f45c490ce297423e6c5ea
USE proyecto2;

-- =================================================================================
-- 1. Desplegar para cada elección el país y el partido político que obtuvo mayor
-- porcentaje de votos en su país. Debe desplegar el nombre de la elección, el
-- año de la elección, el país, el nombre del partido político y el porcentaje que
-- obtuvo de votos en su país.
-- =================================================================================

SELECT eleccion, year, pais, partido, ((porpartido.por_partido*100/total)) FROM (
	SELECT eleccion, year, pais, SUM(votos) AS total FROM (
		SELECT (r.illiterate + r.alphabet) as votos, e.name AS eleccion, e.year, p.name as partido, c.name as pais
			FROM RESULT r
			INNER JOIN ELECTION e ON e.election_id = r.election_id 
			INNER JOIN PARTY p ON p.party_id = r.party_id
			INNER JOIN TOWN t ON t.town_id = r.town_id
			INNER JOIN DEPTO d ON d.depto_id = t.depto_id
			INNER JOIN REGION re ON re.region_id = d.region_id
			INNER JOIN COUNTRY c ON c.country_id = re.country_id 
	) AS detail_p GROUP BY eleccion, year, pais
) AS totales 
	INNER JOIN (
		SELECT SUM(votos) AS por_partido, pais AS pais2, partido FROM (
			SELECT (r.illiterate + r.alphabet) as votos, e.name AS eleccion, e.year, p.name as partido, c.name as pais
				FROM RESULT r
				INNER JOIN ELECTION e ON e.election_id = r.election_id 
				INNER JOIN PARTY p ON p.party_id = r.party_id
				INNER JOIN TOWN t ON t.town_id = r.town_id
				INNER JOIN DEPTO d ON d.depto_id = t.depto_id
				INNER JOIN REGION re ON re.region_id = d.region_id
				INNER JOIN COUNTRY c ON c.country_id = re.country_id 
		) AS detail_p GROUP BY pais, partido
    ) AS porpartido ON porpartido.pais2 = totales.pais; 
        
 
 select * from party;
 select * from election;
 select * from country;
  select * from town;
 
select c.name, r.name, d.name, t.name from toWn t
	INNER JOIN DEPTO d ON d.depto_id = t.depto_id 
    INNER JOIN REGION r ON r.region_id = d.region_id 
	INNER JOIN COUNTRY c ON c.country_id = r.country_id ;
   
 
-- =================================================================================
-- 2. Desplegar total de votos y porcentaje de votos de mujeres por departamento
-- y país. El ciento por ciento es el total de votos de mujeres por país. (Tip:
-- Todos los porcentajes por departamento de un país deben sumar el 100%)
-- =================================================================================

SELECT pais, departamento, SUM(votos) AS total FROM (
		SELECT (r.illiterate + r.alphabet) as votos, d.name AS departamento, c.name as pais
			FROM RESULT r
			INNER JOIN ELECTION e ON e.election_id = r.election_id 
			INNER JOIN PARTY p ON p.party_id = r.party_id
			INNER JOIN TOWN t ON t.town_id = r.town_id
			INNER JOIN DEPTO d ON d.depto_id = t.depto_id
			INNER JOIN REGION re ON re.region_id = d.region_id
			INNER JOIN COUNTRY c ON c.country_id = re.country_id 
            INNER JOIN SEX s ON s.sex_id = r.sex_id 
            WHERE s.name = 'mujeres'
	) AS detail_p GROUP BY pais, departamento;


SELECT pais, SUM(votos) AS total FROM (
		SELECT (r.illiterate + r.alphabet) as votos, d.name AS departamento, c.name as pais
			FROM RESULT r
			INNER JOIN ELECTION e ON e.election_id = r.election_id 
			INNER JOIN PARTY p ON p.party_id = r.party_id
			INNER JOIN TOWN t ON t.town_id = r.town_id
			INNER JOIN DEPTO d ON d.depto_id = t.depto_id
			INNER JOIN REGION re ON re.region_id = d.region_id
			INNER JOIN COUNTRY c ON c.country_id = re.country_id 
            INNER JOIN SEX s ON s.sex_id = r.sex_id 
            WHERE s.name = 'mujeres'
	) AS detail_p GROUP BY pais;


-- =================================================================================
-- 3. Desplegar el nombre del país, nombre del partido político y número de
-- alcaldías de los partidos políticos que ganaron más alcaldías por país.
-- =================================================================================


-- =================================================================================
-- 4. Desplegar todas las regiones por país en las que predomina la raza indígena.
-- Es decir, hay más votos que las otras razas.
-- =================================================================================

SELECT pais, region, SUM(votos) AS total FROM (
		SELECT (r.illiterate + r.alphabet) as votos, re.name AS region, c.name as pais
			FROM RESULT r
			INNER JOIN ELECTION e ON e.election_id = r.election_id 
			INNER JOIN PARTY p ON p.party_id = r.party_id
			INNER JOIN TOWN t ON t.town_id = r.town_id
			INNER JOIN DEPTO d ON d.depto_id = t.depto_id
			INNER JOIN REGION re ON re.region_id = d.region_id
			INNER JOIN COUNTRY c ON c.country_id = re.country_id 
            INNER JOIN RACE ra ON ra.race_id = r.race_id 
            WHERE ra.name = 'INDIGENAS'
	) AS detail_p GROUP BY pais, region;

-- =================================================================================
-- 5. Desplegar el nombre del país, el departamento, el municipio y la cantidad de
-- votos universitarios de todos aquellos municipios en donde la cantidad de
-- votos de universitarios sea mayor que el 25% de votos de primaria y menor
-- que el 30% de votos de nivel medio. Ordene sus resultados de mayor a
-- menor.
-- =================================================================================

-- =================================================================================
-- 6. Desplegar el porcentaje de mujeres universitarias y hombres universitarios
-- que votaron por departamento, donde las mujeres universitarias que votaron
-- fueron más que los hombres universitarios que votaron.
-- =================================================================================

-- =================================================================================
-- 7. Desplegar el nombre del país, la región y el promedio de votos por
-- departamento. Por ejemplo: si la región tiene tres departamentos, se debe
-- sumar todos los votos de la región y dividirlo dentro de tres (número de
-- departamentos de la región).
-- =================================================================================

-- =================================================================================
-- 8. Desplegar el total de votos de cada nivel de escolaridad (primario, medio,
-- universitario) por país, sin importar raza o sexo.
-- =================================================================================

-- =================================================================================
-- 9. Desplegar el nombre del país y el porcentaje de votos por raza.
-- =================================================================================

SELECT pais, raza, ((por_raza*100)/total ) AS votos_por_raza FROM (
	SELECT pais, raza, SUM(votos) AS por_raza FROM (
		SELECT (r.illiterate + r.alphabet) as votos, ra.name AS raza, c.name as pais
			FROM RESULT r
			INNER JOIN ELECTION e ON e.election_id = r.election_id 
			INNER JOIN PARTY p ON p.party_id = r.party_id
			INNER JOIN TOWN t ON t.town_id = r.town_id
			INNER JOIN DEPTO d ON d.depto_id = t.depto_id
			INNER JOIN REGION re ON re.region_id = d.region_id
			INNER JOIN COUNTRY c ON c.country_id = re.country_id 
            INNER JOIN RACE ra ON ra.race_id = r.race_id 
	) AS detail_p GROUP BY pais, raza
) AS consulta1 
	INNER JOIN (
			SELECT pais AS pais2, SUM(votos) AS total FROM (
				SELECT (r.illiterate + r.alphabet) as votos, ra.name AS raza, c.name as pais
					FROM RESULT r
					INNER JOIN ELECTION e ON e.election_id = r.election_id 
					INNER JOIN PARTY p ON p.party_id = r.party_id
					INNER JOIN TOWN t ON t.town_id = r.town_id
					INNER JOIN DEPTO d ON d.depto_id = t.depto_id
					INNER JOIN REGION re ON re.region_id = d.region_id
					INNER JOIN COUNTRY c ON c.country_id = re.country_id 
					INNER JOIN RACE ra ON ra.race_id = r.race_id 
			) AS detail_p GROUP BY pais
    ) AS consulta2 ON pais2 = pais;

-- =================================================================================
-- 10.Desplegar el nombre del país en el cual las elecciones han sido más
-- peleadas. Para determinar esto se debe calcular la diferencia de porcentajes
-- de votos entre el partido que obtuvo más votos y el partido que obtuvo menos
-- votos.
-- =================================================================================


-- TODO: AQUI

-- =================================================================================
-- 11. Desplegar el total de votos y el porcentaje de votos emitidos por mujeres
-- indígenas alfabetas.
-- =================================================================================

-- =================================================================================
-- 12.Desplegar el nombre del país, el porcentaje de votos de ese país en el que
-- han votado mayor porcentaje de analfabetas. (tip: solo desplegar un nombre
-- de país, el de mayor porcentaje).
-- =================================================================================

-- =================================================================================
-- 13.Desplegar la lista de departamentos de Guatemala y número de votos
-- obtenidos, para los departamentos que obtuvieron más votos que el
-- departamento de Guatemala.
-- =================================================================================