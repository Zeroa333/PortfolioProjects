Select * 
From PortfolioProject.dbo.CovidDeaths$
WHERE continent is not null
order by 3,4

--Select * 
--From [PortfolioProject].[dbo].[CovidVaccinations]
--order by 3,4

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases,total_deaths, population
From PortfolioProject.dbo.CovidDeaths$
WHERE continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of daying in your country

Select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
From PortfolioProject.dbo.CovidDeaths$
where location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got COVID


Select location, date, population,total_cases,(total_cases/population)*100 as Infected_Percentage
From PortfolioProject.dbo.CovidDeaths$
where location like '%germany%'
order by 1,2


-- Highest infection rate around the world compared to population

Select location, population,max(total_cases) as Highest_Infection_count,max((total_cases/population))*100 as Infected_Percentage
From PortfolioProject.dbo.CovidDeaths$
--where location like '%germany%'
group by location, population
order by Infected_Percentage desc

-- Let's break this down by continent

Select continent, MAX(cast(total_deaths as int)) as Total_death_count
From PortfolioProject..CovidDeaths$
--where location like '%germany%'
WHERE continent is not null
group by continent
order by Total_death_count desc


-- Showing Countries with the highest Death Count Population

Select location, MAX(cast(total_deaths as int)) as Total_death_count
From PortfolioProject..CovidDeaths$
--where location like '%germany%'
WHERE continent is null
group by location
order by Total_death_count desc

-- Showing the continent  with the highest deat count per population
Select continent, MAX(cast(total_deaths as int)) as Total_death_count
From PortfolioProject..CovidDeaths$
--where location like '%germany%'
WHERE continent is not null
group by continent
order by Total_death_count desc


-- Global Numbers
Select date, sum(new_cases) as Total_cases, SUM(cast(new_deaths as int)) AS Total_death, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
From PortfolioProject.dbo.CovidDeaths$
where continent is not null
group by date
order by 1,2

Select sum(new_cases) as Total_cases, SUM(cast(new_deaths as int)) AS Total_death, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
From PortfolioProject.dbo.CovidDeaths$
where continent is not null
--group by date
order by 1,2

-- Covid Vaccionations
Select * 

From PortfolioProject..CovidVaccinations

-- JOining tables for looking Total Population vs Vaccinations

Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.Location, dea.date) as rolling_vaccination,
(rolling_vaccination/population)*100 
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccionations, rolling_vaccination) AS (
    SELECT 
        dea.continent,dea.location, dea.date,dea.population, vac.new_vaccinations,SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.date ROWS UNBOUNDED PRECEDING) AS rolling_vaccination
    FROM 
        PortfolioProject..CovidDeaths$ dea
    JOIN 
        PortfolioProject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL
)
SELECT * FROM PopvsVac
ORDER BY Location, Date;

-- TEMP TABLE


CREATE TABLE #PercentPopulationVaccionated
(
Continent nvarchar (255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rolling_vaccination numeric

)
insert into #PercentPopulationVaccionated
Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.Location, dea.date) as rolling_vaccination
--,(rolling_vaccination/population)*100 
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

SELECT *, (rolling_vaccination/population)*100 
FROM #PercentPopulationVaccionated
order by 2,3



-- Creating View to store data for later VIZ

create view PercentPopulationVaccionated as
Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.Location, dea.date) as rolling_vaccination
--,(rolling_vaccination/population)*100 
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

-- View
select *
from PercentPopulationVaccionated



