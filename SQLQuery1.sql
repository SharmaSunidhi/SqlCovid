SELECT * 
FROM PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2

-- Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where location like '%state%'
and continent is not null
order by 1,2

-- Total Cases vs Population

SELECT location, date, total_cases, population, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
order by 1,2

-- Countries with Highest Infection Rate

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
group by location, population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc


--By Continent

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


-- Continents with Highest Death Count per population


SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


-- Total Population vs Vaccinations

select Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vaccinations.new_vaccinations, 
SUM(Cast(Vaccinations.new_vaccinations as float)) OVER (partition by Deaths.location order by Deaths.location, Deaths.date) as PeopleVaccinated
from PortfolioProject..CovidDeaths as Deaths
join PortfolioProject..CovidVaccinations as Vaccinations
On Deaths.location = Vaccinations.location
and Deaths.date = Vaccinations.date
where Deaths.continent is not null
order by 2,3


-- Using CTE


With PopVsVac(continent, location, date, population, new_vaccinations, PeopleVaccinated) 
as
(
select Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vaccinations.new_vaccinations, 
SUM(Cast(Vaccinations.new_vaccinations as float)) OVER (partition by Deaths.location order by Deaths.location, Deaths.date) as PeopleVaccinated
from PortfolioProject..CovidDeaths as Deaths
join PortfolioProject..CovidVaccinations as Vaccinations
On Deaths.location = Vaccinations.location
and Deaths.date = Vaccinations.date
where Deaths.continent is not null
)
select *, (PeopleVaccinated/population)*100
from PopVsVac


-- Temp table


Drop table if exists #PercentPopulationVaccinated 
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date nvarchar(255),
Population nvarchar(255),
new_vaccinations numeric,
PeopleVaccinated nvarchar(255)
)

Insert into #PercentPopulationVaccinated
select Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vaccinations.new_vaccinations, 
SUM(Cast(Vaccinations.new_vaccinations as float)) OVER (partition by Deaths.location order by Deaths.location, Deaths.date) as PeopleVaccinated
from PortfolioProject..CovidDeaths as Deaths
join PortfolioProject..CovidVaccinations as Vaccinations
On Deaths.location = Vaccinations.location
and Deaths.date = Vaccinations.date
where Deaths.continent is not null

select *, (cast(PeopleVaccinated as float)/population)*100
from #PercentPopulationVaccinated


-- Creating View to store data for Visualizations

Create View PercentPopulationVaccinated
as
select Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vaccinations.new_vaccinations, 
SUM(Cast(Vaccinations.new_vaccinations as float)) OVER (partition by Deaths.location order by Deaths.location, Deaths.date) as PeopleVaccinated
from PortfolioProject..CovidDeaths as Deaths
join PortfolioProject..CovidVaccinations as Vaccinations
On Deaths.location = Vaccinations.location
and Deaths.date = Vaccinations.date
where Deaths.continent is not null


Select * from PercentPopulationVaccinated