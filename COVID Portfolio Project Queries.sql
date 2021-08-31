SELECT *
FROM CovidDeaths
where continent is not null
ORDER BY 3, 4


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS death_percentage
FROM coviddeaths
WHERE location LIKE '%Canada%'
AND continent IS NOT NULL
ORDER BY 1,2


-- Looking at Total Cases vs Population (what percentage of population got the virus)

SELECT location, date, population, total_cases, (total_cases/population) * 100 AS percent_population_infected
FROM CovidDeaths
WHERE location LIKE '%Canada%'
AND continent IS NOT NULL
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population)) * 100 AS percent_population_infected
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC

-- Countries with the Highest Death Count
SELECT location, MAX(cast(total_deaths as int)) AS highest_death_count
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

-- Continents with the Highest Death Count
SELECT continent, MAX(cast(total_deaths as int)) AS highest_death_count
FROM CovidDeaths
WHERE continent IS NOT  NULL
GROUP BY continent
ORDER BY 2 DESC


-- Finding the days where the new case vs. new death rate percentage is the highest

SELECT date, SUM(cast(new_cases as int)) as total_new_cases, SUM(cast(new_deaths as int)) as total_new_deaths, (SUM(cast(new_deaths AS int))/SUM(new_cases) * 100) AS death_percentage  -- SUM(cast(total_deaths as int)) AS total_deaths_per_day, (total_deaths/total_cases) * 100 AS death_percentage
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP by date
ORDER BY 4 DESC


-- Vaccination rates expressed as a rolling percentage of the total population

WITH PopvsVac (continent, location, date, population, new_vaccinations, vaccination_roll_count)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as vaccination_roll_count
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (vaccination_roll_count/population) * 100 AS vaccination_roll_pct
FROM PopvsVac
ORDER BY 2, 3

-- Creating View to store data for later visualizations

Create View percent_people_vaccinated AS
WITH PopvsVac (continent, location, date, population, new_vaccinations, vaccination_roll_count)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as vaccination_roll_count
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (vaccination_roll_count/population) * 100 AS vaccination_roll_pct
FROM PopvsVac