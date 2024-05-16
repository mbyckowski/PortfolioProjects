USE [Portfolio Project]

SELECT *
FROM dbo.CovidDeaths
Order by 3,4

--Select *
--From dbo.CovidVaccinations
--Order By 3,4 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths
WHERE continent is not null
Order by 1,2


--Exploring Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
FROM dbo.CovidDeaths
--Where location like '%states%'
WHERE continent is not null
Order by 1,2



--Exploring Total Cases vs Population 
--Shows what percentage of population tested positive for Covid over time

SELECT location, date, Population, total_cases, (total_cases/population)*100 as PercentofPopulationInfected
FROM dbo.CovidDeaths
--Where location like '%states%'
WHERE continent is not null
Order by 1,2


--Exploring Countries with Highest Infection Rate compared to Population 

SELECT location, Population, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases)/population)*100 as PercentofPopulationInfected
FROM dbo.CovidDeaths
--Where location like '%states%' 
WHERE continent is not null
Group By location, population
Order by PercentofPopulationInfected desc 


--Exploring Countries with the highest death count

SELECT location, MAX(cast(total_deaths as float)) as TotalDeathCount
FROM dbo.CovidDeaths
--Where location like '%states%' 
WHERE continent is not null
Group By location
Order by TotalDeathCount desc 


--Exploring continents with the highest death count


with MaxByCountry as (
SELECT location, continent, MAX(cast(total_deaths as float)) as TotalDeathCount
FROM [Portfolio Project].dbo.CovidDeaths
--Where location like '%states%' 
WHERE continent is not null AND location not IN (
'World',
'High income',
'Upper middle income',
'Europe',
'North America',
'Asia',
'South America',
'Lower middle income',
'European Union',
'Africa',
'Low income',
'Oceania'
)
Group By location, continent
)

SELECT continent, sum(TotalDeathCount) as TotalDeathCount
FROM MaxByCountry
GROUP BY continent
ORDER BY TotalDeathCount desc



--Global Numbers 

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/NULLIF(SUM(new_cases),0))*100 as DeathPercentage
FROM dbo.CovidDeaths
--Where location like '%states%'
WHERE continent is not null
--Group By date
Order by 1,2


--Exploring Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinations
FROM [Portfolio Project].dbo.CovidDeaths dea
Join [Portfolio Project].dbo.CovidVaccinations vac
On dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null 
Order By 2,3


--USE CTE to Determine Percentage of People Vaccinated in each country

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinations)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinations
FROM dbo.CovidDeaths dea
Join dbo.CovidVaccinations vac
On dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null 
--Order By 2,3
)
Select *, (RollingVaccinations/Population)*100 as PercentPopVaccinated
FROM PopvsVac
Order by 2,3


--Creating Views to store data for visualizations 

Create View PercentPopulationVaccinated as
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinations)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinations
FROM dbo.CovidDeaths dea
Join dbo.CovidVaccinations vac
On dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null 
--Order By 2,3
)
Select *, (RollingVaccinations/Population)*100 as PercentPopVaccinated
FROM PopvsVac
--Order by 2,3


Create View PercentPopulationInfected as
SELECT location, Population, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases)/population)*100 as PercentofPopulationInfected
FROM dbo.CovidDeaths
--Where location like '%states%' 
WHERE continent is not null
Group By location, population
--Order by PercentofPopulationInfected desc 

