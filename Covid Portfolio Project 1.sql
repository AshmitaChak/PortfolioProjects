Select *
From PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations$
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
order by 1,2


-- Looking at Total cases vs Total deaths
-- Shows the likelihood of dying if contracting Covid 
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as  DeathPercentage
From PortfolioProject..CovidDeaths$
where location like 'India'
order by 1,2


-- Looking at Total cases vs Population
-- Shows what part of the population contracted Covid
Select location, date, population, total_cases, (total_cases/population)*100 as  ContractionPercentage
From PortfolioProject..CovidDeaths$
where location like 'India'
order by 1,2


-- Looking at countries with Highest Infection rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as  PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--where location like 'India'
group by location, population
order by PercentPopulationInfected desc


-- Showing Countried with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--where location like 'India'
where continent is not null
group by location
order by TotalDeathCount desc


-- Let's break things up by continent


-- Showing the continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--where location like 'India'
where continent is  not null
group by continent
order by TotalDeathCount desc


-- Global numbers

Select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage-- , total_deaths, (total_deaths/total_cases)*100 as  DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not null
group by date
order by 1,2


-- Looking at Total population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3



-- USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


-- TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
Create Table  #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
-- where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated



-- Cresting View to store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
 where dea.continent is not null
--order by 2,3
