--COVID 19 DATA EXPLORATION

--SKILLS: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types


--FIRST QUERY 

SELECT *
FROM Portfolio_Projects..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 3,4


SELECT *
FROM Portfolio_Projects..CovidVaccinations
WHERE location IS NOT NULL
ORDER BY 3,4

--SELECT THE DATA WE NEED

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_Projects..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


--TOTAL CASES VS TOTAL DEATH (This shows likelihood of dying if you contract covid in your country)

SELECT location,total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM Portfolio_Projects..CovidDeaths
WHERE location = 'Nigeria'
AND continent IS NOT NULL
ORDER BY 1,2


--TOTAL CASES VS POPULATION  (This shows what percentage of population was infected with Covid)

SELECT Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
FROM Portfolio_Projects..CovidDeaths
WHERE location = 'Nigeria'
AND continent IS NOT NULL
ORDER BY 1,2

--COUNTRIES WITHT HE HIGHEST INFECTION RATE COMPARED TO POPULATION 

SELECT Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
FROM Portfolio_Projects..CovidDeaths
WHERE location = 'Nigeria'
AND continent IS NOT NULL
ORDER BY  PercentPopulationInfected desc


--COUNTRIES WITH THE HIGHEST DEATH COUNT PER POPULATION 

SELECT location, MAX(cast(total_deaths as int)) as Total_death_count
FROM Portfolio_Projects..CovidDeaths
WHERE continent IS NOT NULL
--AND location = 'Nigeria'
GROUP BY location
ORDER BY Total_death_count desc


--GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(CONVERT(int, new_deaths)) as total_death, SUM(CONVERT(int,new_deaths))/SUM(new_cases)*100 as Death_Percentage
FROM Portfolio_Projects..CovidDeaths
WHERE continent IS NOT NULL
--AND location = 'Nigeria'
GROUP BY date
ORDER BY 1,2 


 --TOTAL POPULATION VS VACCINATIONS (This shows Percentage of Population that has recieved at least one Covid Vaccine)


 SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccine.new_vaccinations, SUM(CONVERT(int,vaccine.new_vaccinations)) 
 OVER (Partition By deaths.location Order By deaths.location, deaths.date) AS Present_vaccinated_people
 FROM Portfolio_Projects..CovidDeaths deaths
 Join Portfolio_Projects..CovidVaccinations vaccine
    On deaths.location = vaccine.location
	and deaths.date = vaccine.date 
WHERE deaths.continent IS NOT NULL
ORDER BY 2,3


--USE CTE

WITH Pop_Vs_vac (Continent, location, date, population, Present_vaccinated_people, new_vaccinations)
AS
(
SELECT deaths.continent, deaths.location, deaths.date, CONVERT(bigint,deaths.population), vaccine.new_vaccinations, SUM(CONVERT(bigint,vaccine.new_vaccinations)) 
 OVER (Partition By deaths.location Order By deaths.location, deaths.date) AS Present_vaccinated_people
 FROM Portfolio_Projects..CovidDeaths deaths
 Join Portfolio_Projects..CovidVaccinations vaccine
    On deaths.location = vaccine.location
	and deaths.date = vaccine.date 
WHERE deaths.continent IS NOT NULL
)
SELECT *, ( Present_vaccinated_people/ population)*100
FROM Pop_Vs_vac

--OR

--TEMP TABLE 

DROP TABLE IF EXISTS #Percent_Population_Vaccinated
CREATE TABLE #Percent_Population_Vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population bigint,
new_vaccinations bigint,
Present_vaccinated_people bigint
)

INSERT INTO #Percent_Population_Vaccinated

SELECT deaths.continent, deaths.location, deaths.date, CONVERT(bigint,deaths.population) AS population, vaccine.new_vaccinations, SUM(CONVERT(bigint,vaccine.new_vaccinations)) 
 OVER (Partition By deaths.location Order By deaths.location, deaths.date) AS Present_vaccinated_people
 FROM Portfolio_Projects..CovidDeaths deaths
 Join Portfolio_Projects..CovidVaccinations vaccine
    On deaths.location = vaccine.location
	and deaths.date = vaccine.date 
WHERE deaths.continent IS NOT NULL
ORDER BY 2,3

SELECT *, ( Present_vaccinated_people/population)*100
FROM #Percent_Population_Vaccinated


 
 
 
--CREATING VIEW FOR LATER VISUALIZATION

CREATE VIEW Percent_Population_Vaccinated AS
SELECT deaths.continent, deaths.location, deaths.date, CONVERT(bigint,deaths.population) as population, vaccine.new_vaccinations, SUM(CONVERT(bigint,vaccine.new_vaccinations)) 
 OVER (Partition By deaths.location Order By deaths.location, deaths.date) AS Present_vaccinated_people
 FROM Portfolio_Projects..CovidDeaths deaths
 Join Portfolio_Projects..CovidVaccinations vaccine
    On deaths.location = vaccine.location
	and deaths.date = vaccine.date 
WHERE deaths.continent IS NOT NULL

 

 

 

