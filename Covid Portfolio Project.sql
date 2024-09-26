ALTER TABLE vaccinations (
	iso_code VARCHAR (100),
	continent VARCHAR (100),
	location VARCHAR (100),
	date DATE, 
	new_tests INT, 
	total_tests INT, 
	total_tests_per_thousand FLOAT, 
	new_tests_per_thousand FLOAT, 
	new_tests_smoothed INT, 
	new_tests_smoothed_per_thousand FLOAT, 
	positive_rate FLOAT, 
	tests_per_case FLOAT, 
	test_units VARCHAR (100),
	total_vaccinations INT, 
	people_vaccinated INT, 
	people_fully_vaccinated INT, 
	new_vaccinations INT, 
	new_vaccinations_smoothed INT, 
	total_vaccinations_per_hundred FLOAT, 
	people_vaccinated_per_hundred FLOAT, 
	people_fully_vaccinated_per_hundred FLOAT, 
	new_vaccinations_smoothed_per_million FLOAT, 
	stringency_index FLOAT, 
	population_density FLOAT, 
	median_age FLOAT, 
	aged_65_older FLOAT,
	aged_70_older FLOAT, 
	gdp_per_capita FLOAT, 
	extreme_poverty FLOAT, 
	cardiovasc_death_rate FLOAT, 
	diabetes_prevalence FLOAT, 
	female_smokers FLOAT,
	male_smokers FLOAT,
	handwashing_facilities FLOAT, 
	hospital_beds_per_thousand FLOAT,
	life_expectancy FLOAT,
	human_development_index FLOAT;
)

SELECT *
FROM deaths
WHERE continent is NOT NULL
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM deaths
ORDER BY 1, 2

--Looking at toal cases vs total deaths

SELECT location, date, total_cases, total_deaths, ROUND((total_deaths::numeric  / total_cases::numeric) * 100, 2) as death_percentage
FROM deaths
ORDER BY 1, 2

SELECT location, date, total_cases, total_deaths, ROUND((total_deaths::numeric  / total_cases::numeric) * 100, 2) as death_percentage
FROM deaths
WHERE location LIKE '%States%'
ORDER BY 1, 2

SELECT location, date, total_cases, total_deaths, ROUND((total_deaths::numeric  / total_cases::numeric) * 100, 2) as death_percentage
FROM deaths
WHERE location LIKE '%States%'
ORDER BY 1, 2

-- Looking at the total cases vs population
SELECT location, date, total_cases, population, ROUND((total_cases::numeric  / population::numeric) * 100, 2) as PercentPopInfected
FROM deaths
WHERE location LIKE '%States%'
ORDER BY 1, 2

--Looking at population with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases::numeric / population::numeric)) * 100 as PercentPopInfected
FROM deaths
GROUP BY location, population
ORDER BY percentpopinfected DESC

--Showing countries with highest death count per population

SELECT location, MAX(total_deaths) as totaldeathcount
FROM deaths
WHERE continent is NOT NULL 
GROUP BY location
ORDER BY totaldeathcount DESC

--Lets break things down by continent

SELECT continent, MAX(total_deaths) as totaldeathcount
FROM deaths
WHERE continent is NOT NULL 
GROUP BY continent
ORDER BY totaldeathcount DESC

SELECT location, MAX(total_deaths) as totaldeathcount
FROM deaths
WHERE continent is NULL 
GROUP BY location
ORDER BY totaldeathcount DESC

SELECT continent, MAX(total_deaths) as totaldeathcount
FROM deaths
WHERE continent is NOT NULL 
GROUP BY continent
ORDER BY totaldeathcount DESC

-- Showing the continents with the highest death count per population

SELECT continent, MAX(total_deaths) as totaldeathcount
FROM deaths
WHERE continent is NOT NULL 
GROUP BY continent
ORDER BY totaldeathcount DESC

--Global numbers
SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths::numeric) / SUM (new_cases::numeric) * 100 AS deathpercentage
FROM deaths
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1, 2

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths::numeric) / SUM (new_cases::numeric) * 100 AS deathpercentage
FROM deaths
WHERE continent is NOT NULL
--GROUP BY date
ORDER BY 1, 2

SELECT *
FROM vaccinations

SELECT *
FROM deaths dea
JOIN vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date

-- Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vacc
, (rolling_people_vacc)
FROM deaths dea
JOIN vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

--USE CTE

WITH PopvsVAC (contintent, location, date, population, new_vaccinations, rolling_people_vacc)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vacc
FROM deaths dea
JOIN vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3
)
SELECT *, ((rolling_people_vacc::numeric / population::numeric) * 100)
FROM PopvsVac

-- TEMP Table

DROP TABLE if exists percentpopulationvaccinated;
Create TABLE percentpopulationvaccinated
( 
continent VARCHAR (255),
location VARCHAR (255),
DATE date, 
Population numeric, 
new_vaccinations numeric, 
rolling_people_vacc numeric
);

INSERT INTO percentpopulationvaccinated (continent, location, date, population, new_vaccinations, rolling_people_vacc)
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location) AS rolling_people_vacc
FROM deaths dea
JOIN vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3;

SELECT *, (rolling_people_vacc::numeric / population::numeric) * 100
FROM percentpopulationvaccinated

-- Creating VIEW to store data for later vizualizations

Create VIEW percentpopulationvaccinatedVIZ as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location) AS rolling_people_vacc
FROM deaths dea
JOIN vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

