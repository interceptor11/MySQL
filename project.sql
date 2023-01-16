alter table coviddeaths change ï»¿iso_code iso_code text;
alter table covidvaccinations change ï»¿iso_code iso_code text;

set sql_safe_updates = 0;

UPDATE coviddeaths SET continent = NULL WHERE continent = '';
UPDATE covidvaccinations SET continent = NULL WHERE continent = '';

use covid19;

select location,date,total_cases,new_cases,total_deaths,population
from coviddeaths
order by location,date;
-- ----------------------------------------------------------------- --

-- Looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country

select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from coviddeaths
order by location,date;



-- Looking at total cases vs population
-- shows what percentage of population got covid

select location,date,total_cases,population, (total_cases/population)*100 as contractionpercentage
from coviddeaths
order by location,date;



-- Looking at countries with highest infection rate compared to population

select location,population,max(total_cases) as highestinfectioncount, max((total_cases/population)*100) as percentpopulationinfected
from coviddeaths
group by location,population
order by percentpopulationinfected desc;



-- showing countries with highest death count per population

select location,max(convert (total_deaths, decimal)) as totaldeathcount
from coviddeaths
where continent is not null
group by location
order by totaldeathcount desc;



-- showing continents with highest death count per population

select continent, max(convert (total_deaths, decimal)) as totaldeathcount -- select operation applied after where clause hence we use subquery 
from coviddeaths
where continent is not null
group by continent
order by totaldeathcount desc;



-- Global count

select date,sum(new_cases) as 'Total Cases',sum(new_deaths) as 'Total Deaths', sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from coviddeaths
where continent is not null
group by date
order by date,'Total Cases';



-- total population vs vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from coviddeaths dea
join covidvaccinations vac using(location,date) 
where dea.continent is not null
order by dea.location,dea.date;


-- vaccination percentage
-- with CTE (common table expression)
with popvsVac (continent,location,date,population,new_vaccinations,rollingpeoplevaccinated) 
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(vac.new_vaccinations,decimal)) over 
(partition by dea.location order by dea.location,dea.date ) rollingpeoplevaccinated
from coviddeaths dea
join covidvaccinations vac using(location,date) 
where dea.continent is not null
-- order by dea.location,dea.date
)
select * , (rollingpeoplevaccinated/population)*100 '%rollingpeoplevaccinated'
from popvsVac;
