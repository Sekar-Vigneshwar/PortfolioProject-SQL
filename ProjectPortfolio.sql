select *
from CovidDeaths
order by 3,4

--Select *
--from CovidVaccination
--order by 3,4

-- Select the data that we are going to be using

select location, Date , total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2

-- Looking at total cases vs Total deaths
-- shows the likelihood of dying if you contractr covid in your country
select location, Date , total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%india%'
order by 1,2

--alter table CovidDeaths
--alter Column total_deaths float

--alter table CovidDeaths
--alter Column total_cases float


--looking at total cases vs population
-- shows what percentage of population got covid
select location, Date , total_cases, population, (total_cases/population)*100 as PerecentOFPopulationInfected
from CovidDeaths
--where location like '%india%'
order by 1,2

-- Looking at countries with highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PerecentOFPopulationInfected
from CovidDeaths
--where location like '%india%'
Group by location, population
order by PerecentOFPopulationInfected desc

-- Shwoing Countries with the highest Death Count per Population

select Location,max(total_deaths) as TotalDeathCount
from CovidDeaths
--where location like '%india%'
where continent is not null
Group by Location
order by TotalDeathCount desc

--Let's break Things dowwn by Continent

--Showing the continent with the highest death Count per population

select continent,max(total_deaths) as TotalDeathCount
from CovidDeaths
--where location like '%india%'
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global Numbers

update CovidDeaths
set new_cases = null where new_cases = 0

update CovidDeaths
set new_Deaths = null where new_Deaths = 0

Select date, Sum(new_cases) as totalcases, Sum(new_Deaths),Sum(new_Deaths) / Sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
Group by date
order by 1,2,4

Select Sum(new_cases) as totalcases, Sum(new_Deaths),Sum(new_Deaths) / Sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
--Group by date
order by 1,2

-- looking at total population vs vaccinations

update CovidVaccination
set new_vaccinations=0 where new_vaccinations=null

alter table CovidVaccination
alter column new_vaccinations int
go

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated,
from CovidDeaths Dea
join CovidVaccination vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
order by 2,3

--use CTE

with PopvsVac(continent, location, date, population, new_vaccination,RollingPeopleVaccinated)
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths Dea
join CovidVaccination vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


-- Temp Table

drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population bigint,
new_vaccination bigint,
RollingPeopleVaccinated bigint
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths Dea
join CovidVaccination vac
  on dea.location = vac.location
  and dea.date = vac.date
  --where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- Creating View to store data for later Visualizations

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths Dea
join CovidVaccination vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated

 

