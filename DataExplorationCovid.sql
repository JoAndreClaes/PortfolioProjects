

SELECT *
FROM Covid..CovidDeaths
WHERE continent is not null
ORDER by 3,4

--SELECT *
--FROM Covid..CovidVaccinations
--ORDER by 3,4

-- Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Covid..CovidDeaths
ORDER by 1, 2


-- Looking at total cases vs total deaths (Belgium)

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Covid..CovidDeaths
WHERE location like '%belgium%'
ORDER by 1, 2

-- Looking at total cases vs population

SELECT location, date, population, total_cases, (total_cases/population)*100 as InfectionPercentage
FROM Covid..CovidDeaths
-- WHERE location like '%belgium%'
ORDER by 1, 2


-- Looking at countries with highest infection rate

SELECT location, population, max(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectionPercentage
FROM Covid..CovidDeaths
-- WHERE location like '%belgium%'
GROUP by location, population
ORDER by InfectionPercentage DESC


-- Looking at countries with highest Death Count

SELECT location, max(cast(total_deaths as int)) as TotalDeathCount
FROM Covid..CovidDeaths
WHERE continent is not null
-- WHERE location like '%belgium%'
GROUP by location, population
ORDER by TotalDeathCount DESC


-- Let's break things down by continent

SELECT location, max(cast(total_deaths as int)) as TotalDeathCount
FROM Covid..CovidDeaths
WHERE continent is null
-- WHERE location like '%belgium%'
GROUP by location
ORDER by TotalDeathCount DESC


-- Looking at continents (numbers don't add up)
SELECT continent, max(cast(total_deaths as int)) as TotalDeathCount
FROM Covid..CovidDeaths
WHERE continent is not null
-- WHERE location like '%belgium%'
GROUP by continent
ORDER by TotalDeathCount DESC


-- Global Covid Numbers

SELECT location, max(cast(total_deaths as int)) as TotalDeathCount, max(cast(total_cases as int)) as TotalCases
FROM Covid..CovidDeaths
WHERE location like '%world%'
-- WHERE location like '%belgium%'
GROUP by location
ORDER by TotalDeathCount DESC


-- Global Numbers by Date

SELECT date, sum(cast(new_deaths as int)) as TotalDeathCount, sum(new_cases) as TotalCases, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM Covid..CovidDeaths
WHERE continent is not null
-- WHERE location like '%belgium%'
GROUP by date
ORDER by 1, 2



-- Vaccinations


-- Looking at total population vs vaccinations 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as PeopleVaccinated
-- , (PeopleVaccinated/population)*100
FROM Covid..CovidDeaths dea
JOIN Covid..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER by 2, 3



-- USE CTE

WITH PopVsVac (continent, location, date, population, New_Vaccinations, PeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as PeopleVaccinated
-- , (PeopleVaccinated/population)*100
FROM Covid..CovidDeaths dea
JOIN Covid..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
-- ORDER by 2, 3
)
SELECT *, (PeopleVaccinated/population)*100
FROM PopVsVac



-- TEMP TABLE


DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as PeopleVaccinated
-- , (PeopleVaccinated/population)*100
FROM Covid..CovidDeaths dea
JOIN Covid..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
-- WHERE dea.continent is not null
-- ORDER by 2, 3

SELECT *, (PeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated



-- Creating view to store data for later visualizations


CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as PeopleVaccinated
-- , (PeopleVaccinated/population)*100
FROM Covid..CovidDeaths dea
JOIN Covid..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
-- ORDER by 2, 3


SELECT *
FROM PercentPopulationVaccinated