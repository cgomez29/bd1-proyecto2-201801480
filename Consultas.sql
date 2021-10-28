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
			INNER JOIN PARTY p ON p.party_id = r.party_id
			INNER JOIN ELECTION e ON p.election_id = e.election_id 
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
				INNER JOIN PARTY p ON p.party_id = r.party_id
                INNER JOIN ELECTION e ON p.election_id = e.election_id 
				INNER JOIN TOWN t ON t.town_id = r.town_id
				INNER JOIN DEPTO d ON d.depto_id = t.depto_id
				INNER JOIN REGION re ON re.region_id = d.region_id
				INNER JOIN COUNTRY c ON c.country_id = re.country_id 
		) AS detail_p GROUP BY pais, partido
    ) AS porpartido ON porpartido.pais2 = totales.pais; 

 
-- =================================================================================
-- 2. Desplegar total de votos y porcentaje de votos de mujeres por departamento
-- y país. El ciento por ciento es el total de votos de mujeres por país. (Tip:
-- Todos los porcentajes por departamento de un país deben sumar el 100%)
-- =================================================================================
SELECT pais, departamento, pordepa, ((pordepa*100)/total) FROM (
	SELECT pais, departamento, SUM(votos) AS pordepa FROM (
		SELECT (r.illiterate + r.alphabet) as votos, d.name AS departamento, c.name as pais
			FROM RESULT r
			INNER JOIN PARTY p ON p.party_id = r.party_id
			INNER JOIN ELECTION e ON p.election_id = e.election_id 
			INNER JOIN TOWN t ON t.town_id = r.town_id
			INNER JOIN DEPTO d ON d.depto_id = t.depto_id
			INNER JOIN REGION re ON re.region_id = d.region_id
			INNER JOIN COUNTRY c ON c.country_id = re.country_id 
            INNER JOIN SEX s ON s.sex_id = r.sex_id 
            WHERE s.name = 'mujeres'
	) AS detail_p GROUP BY pais, departamento
) AS consulta1 
	INNER JOIN (
		SELECT pais AS pais2, SUM(votos) AS total FROM (
			SELECT (r.illiterate + r.alphabet) as votos, d.name AS departamento, c.name as pais
				FROM RESULT r
				INNER JOIN PARTY p ON p.party_id = r.party_id
				INNER JOIN ELECTION e ON p.election_id = e.election_id 
				INNER JOIN TOWN t ON t.town_id = r.town_id
				INNER JOIN DEPTO d ON d.depto_id = t.depto_id
				INNER JOIN REGION re ON re.region_id = d.region_id
				INNER JOIN COUNTRY c ON c.country_id = re.country_id 
				INNER JOIN SEX s ON s.sex_id = r.sex_id 
				WHERE s.name = 'mujeres'
		) AS detail_p GROUP BY pais
    ) AS consulta2 ON pais = pais2 ;


-- =================================================================================
-- 3. Desplegar el nombre del país, nombre del partido político y número de
-- alcaldías de los partidos políticos que ganaron más alcaldías por país.
-- =================================================================================
CREATE OR REPLACE VIEW v_consulta3_maximo 
	AS
	SELECT pais, municipio, partido, total, (MAX(total) OVER (PARTITION BY pais, municipio)) AS maximo  FROM (
		SELECT  c.name as pais, re.name as region, d.name as depto, t.name AS municipio, p.name AS partido, SUM(r.illiterate + r.alphabet) AS total
			FROM RESULT r
				INNER JOIN PARTY p ON p.party_id = r.party_id
				INNER JOIN TOWN t ON t.town_id = r.town_id
				INNER JOIN DEPTO d ON d.depto_id = t.depto_id
				INNER JOIN REGION re ON re.region_id = d.region_id
				INNER JOIN COUNTRY c ON c.country_id = re.country_id 
					GROUP BY c.name, re.name, d.name, t.name, p.name
	) AS consulta1
		ORDER BY pais, maximo DESC;

SELECT pais, partido, cantidad, maxi FROM (
	SELECT pais, partido, cantidad, (MAX(cantidad) OVER ( PARTITION BY pais)) AS maxi FROM (
		SELECT pais, partido, COUNT(partido) AS cantidad
		FROM (
			SELECT pais, municipio, partido, total, maximo
				FROM v_consulta3_maximo
					GROUP BY pais, municipio, partido, total
						HAVING total = maximo
		) AS maximos 
			GROUP BY pais, partido
	) AS consulta1
) AS consulta2
	GROUP BY pais, partido
		HAVING cantidad = maxi;

        
-- =================================================================================
-- 4. Desplegar todas las regiones por país en las que predomina la raza indígena.
-- Es decir, hay más votos que las otras razas.
-- =================================================================================

SELECT pais, region, total FROM (
	SELECT SUM(r.illiterate + r.alphabet) as total, re.name AS region, c.name as pais, ra.name AS raza
		FROM RESULT r
			INNER JOIN PARTY p ON p.party_id = r.party_id
			INNER JOIN ELECTION e ON p.election_id = e.election_id 
			INNER JOIN TOWN t ON t.town_id = r.town_id
			INNER JOIN DEPTO d ON d.depto_id = t.depto_id
			INNER JOIN REGION re ON re.region_id = d.region_id
			INNER JOIN COUNTRY c ON c.country_id = re.country_id 
			INNER JOIN RACE ra ON ra.race_id = r.race_id 
				GROUP BY c.name, re.name, ra.name
				ORDER BY total DESC
) AS todos 
	INNER JOIN (
		SELECT pais AS pais2, region AS region2, MAX(total) AS maximo FROM (
			SELECT SUM(r.illiterate + r.alphabet) as total, re.name AS region, c.name as pais, ra.name AS raza
				FROM RESULT r
					INNER JOIN PARTY p ON p.party_id = r.party_id
					INNER JOIN ELECTION e ON p.election_id = e.election_id 
					INNER JOIN TOWN t ON t.town_id = r.town_id
					INNER JOIN DEPTO d ON d.depto_id = t.depto_id
					INNER JOIN REGION re ON re.region_id = d.region_id
					INNER JOIN COUNTRY c ON c.country_id = re.country_id 
					INNER JOIN RACE ra ON ra.race_id = r.race_id 
						GROUP BY c.name, re.name, ra.name
						ORDER BY total DESC
		) AS tmax GROUP BY pais, region
    ) AS maximos ON pais2 = pais AND region2 = region AND maximo = total
		WHERE raza = 'INDIGENAS';


-- =================================================================================
-- 5. Desplegar el nombre del país, el departamento, el municipio y la cantidad de
-- votos universitarios de todos aquellos municipios en donde la cantidad de
-- votos de universitarios sea mayor que el 25% de votos de primaria y menor
-- que el 30% de votos de nivel medio. Ordene sus resultados de mayor a
-- menor.
-- =================================================================================

SELECT pais, departamento, municipio, (uni*100/total) AS luni, (primario*100/total) AS lprimario, (medio*100/total) AS lmedio FROM (
	SELECT 	c.name AS pais, d.name AS departamento, t.name AS municipio, SUM(r.academic) as uni,
			SUM(r.primary_level) as primario, SUM(r.medium_level) as medio
		FROM RESULT r
			INNER JOIN TOWN t ON t.town_id = r.town_id
			INNER JOIN DEPTO d ON d.depto_id = t.depto_id
			INNER JOIN REGION re ON re.region_id = d.region_id
			INNER JOIN COUNTRY c ON c.country_id = re.country_id 
				GROUP BY c.name, d.name, t.name
) AS consulta1 
	INNER JOIN (
		SELECT c.name AS pais2, d.name AS departamento2, t.name AS municipio2, SUM(alphabet) as total
			FROM RESULT r
				INNER JOIN TOWN t ON t.town_id = r.town_id
				INNER JOIN DEPTO d ON d.depto_id = t.depto_id
				INNER JOIN REGION re ON re.region_id = d.region_id
				INNER JOIN COUNTRY c ON c.country_id = re.country_id 
					GROUP BY c.name, d.name, t.name
					ORDER BY total DESC
    
    ) AS consulta2 ON pais = pais2 AND departamento = departamento2 AND municipio = municipio2
		GROUP BY pais, departamento, municipio
			HAVING luni > (0.25*lprimario) AND luni <(0.3*lmedio);
	
                

-- =================================================================================
-- 6. Desplegar el porcentaje de mujeres universitarias y hombres universitarios
-- que votaron por departamento, donde las mujeres universitarias que votaron
-- fueron más que los hombres universitarios que votaron.
-- =================================================================================

CREATE OR REPLACE VIEW v_consulta6_porcentaje_universitarios
	AS
	SELECT departamento, universitarios, ((individual*100)/total) AS porcentaje FROM (
		SELECT c.name AS pais, d.name AS departamento, s.name AS universitarios, SUM(r.academic) AS individual
			FROM RESULT r
				INNER JOIN TOWN t ON t.town_id = r.town_id
				INNER JOIN DEPTO d ON d.depto_id = t.depto_id
				INNER JOIN REGION re ON re.region_id = d.region_id
				INNER JOIN COUNTRY c ON c.country_id = re.country_id 
				INNER JOIN SEX s ON s.sex_id = r.sex_id 
					GROUP BY c.name, d.name, s.name
	) AS consulta1 
		INNER JOIN (
			SELECT c.name AS pais2, d.name AS departamento2, SUM(r.academic) AS total
				FROM RESULT r
					INNER JOIN TOWN t ON t.town_id = r.town_id
					INNER JOIN DEPTO d ON d.depto_id = t.depto_id
					INNER JOIN REGION re ON re.region_id = d.region_id
					INNER JOIN COUNTRY c ON c.country_id = re.country_id 
					INNER JOIN SEX s ON s.sex_id = r.sex_id 
						GROUP BY c.name, d.name
		) AS consulta2 ON pais2 = pais AND departamento = departamento2
			ORDER BY departamento, porcentaje DESC;
            
SELECT depto, mporcentaje AS Universitarias, hporcentaje AS Universitarios 
	FROM (
		SELECT departamento AS depto, universitarios AS mujeres, porcentaje AS mporcentaje
			FROM v_consulta6_porcentaje_universitarios
				WHERE universitarios = 'mujeres'
    ) AS consulta1 
		INNER JOIN (
			SELECT departamento as depto2, universitarios AS hombres, porcentaje AS hporcentaje
				FROM v_consulta6_porcentaje_universitarios
					WHERE universitarios = 'hombres'
        ) AS consulta2 
			ON depto = depto2
				WHERE mporcentaje > hporcentaje
                 ORDER BY depto, mporcentaje DESC;



-- =================================================================================
-- 7. Desplegar el nombre del país, la región y el promedio de votos por
-- departamento. Por ejemplo: si la región tiene tres departamentos, se debe
-- sumar todos los votos de la región y dividirlo dentro de tres (número de
-- departamentos de la región).
-- =================================================================================

SELECT  pais, region, AVG(total) AS promedio FROM (
	SELECT  c.name as pais, re.name AS region, d.name AS departamento, SUM(r.illiterate + r.alphabet) as total
		FROM RESULT r
			INNER JOIN PARTY p ON p.party_id = r.party_id
			INNER JOIN ELECTION e ON p.election_id = e.election_id 
			INNER JOIN TOWN t ON t.town_id = r.town_id
			INNER JOIN DEPTO d ON d.depto_id = t.depto_id
			INNER JOIN REGION re ON re.region_id = d.region_id
			INNER JOIN COUNTRY c ON c.country_id = re.country_id 
			INNER JOIN RACE ra ON ra.race_id = r.race_id 
				GROUP BY c.name, re.name, d.name
) AS consulta1
	GROUP BY pais, region;

-- =================================================================================
-- 8. Desplegar el total de votos de cada nivel de escolaridad (primario, medio,
-- universitario) por país, sin importar raza o sexo.
-- =================================================================================

SELECT 	c.name as pais, 
		SUM(r.primary_level) AS primario, 
		SUM(r.medium_level) AS medio, 
        SUM(r.academic) AS universitario
	FROM RESULT r
		INNER JOIN TOWN t ON t.town_id = r.town_id
		INNER JOIN DEPTO d ON d.depto_id = t.depto_id
		INNER JOIN REGION re ON re.region_id = d.region_id
		INNER JOIN COUNTRY c ON c.country_id = re.country_id 
			GROUP BY c.name;


-- =================================================================================
-- 9. Desplegar el nombre del país y el porcentaje de votos por raza.
-- =================================================================================

SELECT pais, raza, ((por_raza*100)/total ) AS votos_por_raza FROM (
	SELECT pais, raza, SUM(votos) AS por_raza FROM (
		SELECT (r.illiterate + r.alphabet) as votos, ra.name AS raza, c.name as pais
			FROM RESULT r
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

CREATE OR REPLACE VIEW consulta10_pais_votos_desc
	AS
	SELECT  c.name as pais, SUM(r.illiterate + r.alphabet) as total
		FROM RESULT r
			INNER JOIN PARTY p ON p.party_id = r.party_id
			INNER JOIN ELECTION e ON p.election_id = e.election_id 
			INNER JOIN TOWN t ON t.town_id = r.town_id
			INNER JOIN DEPTO d ON d.depto_id = t.depto_id
			INNER JOIN REGION re ON re.region_id = d.region_id
			INNER JOIN COUNTRY c ON c.country_id = re.country_id 
				GROUP BY c.name, p.name;

SELECT pais, (maximo - menor) AS diferencia FROM (
	SELECT	pais,
		total,
        MAX(total) OVER (PARTITION BY pais) AS maximo,
        MIN(total) OVER (PARTITION BY pais) AS menor
	FROM consulta10_pais_votos_desc
) AS consulta1
	ORDER BY diferencia ASC LIMIT 1;

-- =================================================================================
-- 11. Desplegar el total de votos y el porcentaje de votos emitidos por mujeres
-- indígenas alfabetas.
-- =================================================================================

SELECT pais, ((total_analf*100)/totalA) FROM (
	SELECT  c.name as pais, SUM(r.alphabet) as total_analf
		FROM RESULT r
			INNER JOIN TOWN t ON t.town_id = r.town_id
			INNER JOIN DEPTO d ON d.depto_id = t.depto_id
			INNER JOIN REGION re ON re.region_id = d.region_id
			INNER JOIN COUNTRY c ON c.country_id = re.country_id 
			INNER JOIN RACE ra ON ra.race_id = r.race_id 
			INNER JOIN SEX s ON s.sex_id = r.sex_id 
				WHERE s.name = 'mujeres' AND ra.name = 'INDIGENAS'
				GROUP BY c.name
					ORDER BY total_analf DESC

) AS consulta1 
	INNER JOIN (
		SELECT  c.name as pais2, SUM(r.alphabet + illiterate) as totalA
			FROM RESULT r
				INNER JOIN TOWN t ON t.town_id = r.town_id
				INNER JOIN DEPTO d ON d.depto_id = t.depto_id
				INNER JOIN REGION re ON re.region_id = d.region_id
				INNER JOIN COUNTRY c ON c.country_id = re.country_id 
				INNER JOIN RACE ra ON ra.race_id = r.race_id 
				INNER JOIN SEX s ON s.sex_id = r.sex_id 
					GROUP BY c.name
						ORDER BY totalA DESC
    ) AS consulta2 ON pais2 = pais;


-- =================================================================================
-- 12.Desplegar el nombre del país, el porcentaje de votos de ese país en el que
-- han votado mayor porcentaje de analfabetas. (tip: solo desplegar un nombre
-- de país, el de mayor porcentaje).
-- =================================================================================

SELECT pais, ((analfabetas*100)/total) AS porcentaje_analfabetas FROM (
	SELECT c.name AS pais, SUM(r.illiterate) AS analfabetas
		FROM RESULT r
			INNER JOIN TOWN t ON t.town_id = r.town_id
			INNER JOIN DEPTO d ON d.depto_id = t.depto_id
			INNER JOIN REGION re ON re.region_id = d.region_id
			INNER JOIN COUNTRY c ON c.country_id = re.country_id 
				GROUP BY c.name
					ORDER BY analfabetas DESC LIMIT 1
) AS consulta1 
	INNER JOIN (
		SELECT c.name AS pais2, SUM(r.illiterate+r.alphabet) AS total
			FROM RESULT r
				INNER JOIN TOWN t ON t.town_id = r.town_id
				INNER JOIN DEPTO d ON d.depto_id = t.depto_id
				INNER JOIN REGION re ON re.region_id = d.region_id
				INNER JOIN COUNTRY c ON c.country_id = re.country_id 
					GROUP BY c.name
						ORDER BY total DESC
    ) AS consulta2 ON pais = pais2;

-- =================================================================================
-- 13.Desplegar la lista de departamentos de Guatemala y número de votos
-- obtenidos, para los departamentos que obtuvieron más votos que el
-- departamento de Guatemala.
-- =================================================================================

	SELECT  c.name as pais, d.name, SUM(r.illiterate + r.alphabet) as total
		FROM RESULT r
			INNER JOIN TOWN t ON t.town_id = r.town_id
			INNER JOIN DEPTO d ON d.depto_id = t.depto_id
			INNER JOIN REGION re ON re.region_id = d.region_id
			INNER JOIN COUNTRY c ON c.country_id = re.country_id 
				WHERE c.name = 'GUATEMALA' 
					GROUP BY c.name, d.name
						HAVING total > (
							SELECT SUM(r.illiterate + r.alphabet) AS totalGuate
								FROM RESULT r
									INNER JOIN TOWN t ON t.town_id = r.town_id
									INNER JOIN DEPTO d ON d.depto_id = t.depto_id
									INNER JOIN REGION re ON re.region_id = d.region_id
									INNER JOIN COUNTRY c ON c.country_id = re.country_id 
										WHERE c.name = 'GUATEMALA' AND d.name = 'Guatemala'
											GROUP BY c.name, d.name
												ORDER BY totalGuate DESC
						) 
						ORDER BY total DESC;


