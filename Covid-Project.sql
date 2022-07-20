SELECT *
FROM coviddeaths  
ORDER BY 3,4

SELECT *
FROM covidvaccinations  
ORDER BY 3,4


SELECT location, date, total_cases, new_cases , total_deaths , population 
FROM coviddeaths
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Shows the likelihood of dying if you attract Covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS DeathPercentage
FROM coviddeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

-- Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM coviddeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

-- Countries with highest infection rate compared to population
SELECT location, MAX(total_cases), population, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM coviddeaths
GROUP BY location, population
ORDER BY 5 DESC

-- Countries with highest death count per population
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM coviddeaths
WHERE continent <> ""
GROUP BY location/
ORDER BY 2 DESC

-- BREAKING THINGS DOWN BY CONTINENT
-- Continents with highest death count

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM coviddeaths
WHERE continent = "" AND location NOT LIKE "%income%"
GROUP BY 1
ORDER BY 2 DESC


-- GLOBAL NUMBERS
-- Total aggregate cases, deaths and total death percentage by day
SELECT date, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM coviddeaths
WHERE continent <> "" AND continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Total cases, deaths and death percentage over time
SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM coviddeaths
WHERE continent <> "" AND continent IS NOT NULL
ORDER BY 1,2

-- Looking at total vaccinations vs population

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent <> "" AND dea.continent IS NOT NULL
ORDER BY 2,3

-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent <> "" AND dea.continent IS NOT NULL
ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac



-- TEMP TABLE

DROP TABLE IF EXISTS PercentPopulationVaccinated

CREATE TEMPORARY TABLE PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent <> "" AND dea.continent IS NOT NULL
ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated



-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent <> "" AND dea.continent IS NOT NULL
ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated