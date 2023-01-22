
Select *
From PortfolioProject ..CovidDeaths
Where continent is not null 
order by 3,4


-- Select *
-- From PortfolioProject ..CovidVaccinations
-- order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject ..CovidDeaths
Where continent is not null 
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject ..CovidDeaths
Where location like '%state%'
and continent is not null 
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

Select Location, date,  population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject ..CovidDeaths
-- Where location like '%state%'
order by 1,2



-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject ..CovidDeaths
-- Where location like '%state%'
Group by  Location,  population
order by PercentPopulationInfected desc



-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject ..CovidDeaths
-- Where location like '%state%'
Where continent is not null
Group by  Location
order by TotalDeathCount desc



-- LET'S BREAK THINGS DOWN BY CONTINENT



-- Showing contintents with highest deaths count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject ..CovidDeaths
-- Where location like '%state%'
Where continent is not null
Group by  continent
order by TotalDeathCount desc




-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject ..CovidDeaths
-- Where location like '%state%'
where continent is not null 
-- Group by date
order by 1,2



-- Loooking at Total Population vs Vaccinations


-- USE CTE


With PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject ..CovidDeaths dea
Join PortfolioProject ..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac





-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject ..CovidDeaths dea
Join PortfolioProject ..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
-- Where dea.continent is not null
-- Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject ..CovidDeaths dea
Join PortfolioProject ..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- Order by 2,3