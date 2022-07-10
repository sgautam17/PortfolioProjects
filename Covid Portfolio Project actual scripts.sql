SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4;

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4;

SELECT Location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you are covid +ve in your country

SELECT Location,date,total_cases,total_deaths,(Total_deaths/total_cases)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%India%'
ORDER BY 1,2;

--Looking at Total Cases vs Population
--Shows what %age of population contracted Covid

SELECT Location,date,total_cases,total_deaths,Population,(Total_cases/population)*100 as ContractedPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%India%'
ORDER BY 1,2;

--Looking at countries with highest infection rate compared to Population

SELECT Location,Population,MAX(total_cases) as HighestInfectionCount,
MAX((Total_cases/population)*100) as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%India%'
GROUP BY Location,Population
ORDER BY PercentPopulationInfected DESC;


--Showing the counrtries with highest death count per population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC;

--LET'S BREAK THINGS DOWN BY CONTINENT
--Showing continent with the Highest death per population

SELECT continent,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;

--GLOBAL NUMBERS AS PER DATE

SELECT date,SUM(new_cases) as TotalCases,
SUM(cast(new_deaths as int))as TotalDeaths,SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2;

--GLOBAL NUMBERS AS PER DATE

SELECT SUM(new_cases) as TotalCases,
SUM(cast(new_deaths as int))as TotalDeaths,SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2;

--Looking at Total Population vs Vaccination

SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as INT)) OVER (PARTITION BY dea.location ORDER BY
dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 2,3;

--Use CTE

WITH PopvsVac (Continent,Location,Date,Population,New_Vaccinations,
RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as INT)) OVER (PARTITION BY dea.location ORDER BY
dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *,(RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY
dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	and dea.date=vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *,(RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating View to store data for later visualization

CREATE VIEW PercentagePopulationVaccinated as
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY
dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


SELECT *
FROM PercentagePopulationVaccinated