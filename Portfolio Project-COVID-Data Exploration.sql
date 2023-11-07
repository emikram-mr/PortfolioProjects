
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

------SELECT *
------FROM PortfolioProject..CovidVaccinations
------ORDER BY 3,4

--Select Data I will be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


-- Looking at the Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2


-- Looking at the Total Cases vs Population
-- Shows what % of population got Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS percent_of_population_with_covid
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
ORDER BY 1,2


-- Looking at countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- Showing continents with the highest death count per population


SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount --CAST() is used to change the DATATYPE of total_deaths column from VARCHAR into INT for calculation purposes
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;


SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, 
	SUM(CAST(new_deaths AS INT)) AS total_deaths, --CAST() is to change the DATATYPE of new_deaths from VARCHAR into INT to be used as a calculation
	SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage --CAST() is to change the DATATYPE of new_deaths from VARCHAR into INT to be used as a calculation
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
--GROUP BY date 
ORDER BY 1,2



SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(CAST(v.new_vaccinations AS bigint)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated,
	--(RollingPeopleVaccinated/d.population)*100
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2,3


-- USE CTE

WITH PopvsVac 
	(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
	AS
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(CAST(v.new_vaccinations AS bigint)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
	--(RollingPeopleVaccinated/d.population)*100
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated(
	continent NVARCHAR(255),
	location NVARCHAR(255),
	date DATETIME,
	population NUMERIC,
	new_vaccincations NUMERIC,
	RollingPeopleVaccinated NUMERIC
)
INSERT INTO #PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(CAST(v.new_vaccinations AS bigint)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
	--(RollingPeopleVaccinated/d.population)*100
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
--WHERE d.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated



-- Creating View to store data for later visualizations


CREATE VIEW PercentPopulationVaccinated AS 
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(CAST(v.new_vaccinations AS bigint)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
	--(RollingPeopleVaccinated/d.population)*100
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL
--ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated

-- Creating View to store data for later visualization #2


CREATE VIEW ContinentHighDeathCount AS
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
--ORDER BY TotalDeathCount DESC

SELECT*
FROM ContinentHighDeathCount
