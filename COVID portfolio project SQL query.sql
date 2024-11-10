

select *
from CovidDeaths$

select location, date, total_cases, new_cases, total_deaths,population
from CovidDeaths$

--let us look the data for Total Cases vs Total Deaths united states

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from CovidDeaths$
Where location like '%states%'
order by 1,2

--let us look the data for Total Cases vs Population in the united states

select location, date, population, total_cases, (total_cases/population)*100 as Deathpercentage
from CovidDeaths$
Where location like '%states%'
order by 1,2

--Let us look at countries with highest covid  rate compared to population

select location, population, MAX(total_cases) as HighestCovidCases, MAX((total_cases/population))*100 as PercentPopulationInfected
from CovidDeaths$
Group by location, population
order by PercentPopulationInfected desc

-- showing countries with highest death count per population

select location, population, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
Group by location, population
order by TotalDeathCount desc

-- let's breakdown the number of total death by continent

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers interms of New cases and Total Deaths

select date, SUM(new_cases)
from CovidDeaths$
where continent is not null
Group by date
order by 1,2

select date, SUM(new_cases), SUM(CAST(new_deaths as int))as total_death, SUM(cast(new_deaths as int))/ SUM(New_cases)*100 as DeathPercentage
from CovidDeaths$
where continent is not null
Group by date
order by 1,2

--To get the total number of death globally

select SUM(new_cases), SUM(CAST(new_deaths as int))as total_death, SUM(cast(new_deaths as int))/ SUM(New_cases)*100 as DeathPercentage
from CovidDeaths$
where continent is not null
--Group by date
order by 1,2

--Let's look at the Vaccination Table

select *
from CovidVaccinations$

--Let's join the two table

select dth.continent, dth.location, dth.date, dth.population, vcc.new_vaccinations
from CovidDeaths$ dth join CovidVaccinations$ vcc
on dth.location = vcc.location and dth.date =vcc.date
where dth.continent is not null
order by 2,3

--Let's see total Population vs Vaccination

select dth.continent, dth.location, dth.date, dth.population, vcc.new_vaccinations, 
SUM(CAST(vcc.new_vaccinations as int)) OVER (Partition by dth.location)
from CovidDeaths$ dth join CovidVaccinations$ vcc
on dth.location = vcc.location and dth.date =vcc.date
where dth.continent is not null
order by 2,3

--using CTE

with PopvsVac (continent, location, date, population, new_vaccinations, PeopleVaccinated)
as
(
select dth.continent, dth.location, dth.date, dth.population, vcc.new_vaccinations, 
SUM(CONVERT(int,vcc.new_vaccinations)) OVER (Partition by dth.location order by dth.location, dth.date) as PeopleVaccinated
from CovidDeaths$ dth join CovidVaccinations$ vcc
on dth.location = vcc.location and dth.date = vcc.date
where dth.continent is not null
)
select *, (PeopleVaccinated/population)*100 
 from PopvsVac

 --Using TEMP TABLE

create table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
PeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
select dth.continent, dth.location, dth.date, dth.population, vcc.new_vaccinations, 
SUM(CONVERT(int,vcc.new_vaccinations)) OVER (Partition by dth.location order by dth.location, dth.date) as PeopleVaccinated
from CovidDeaths$ dth join CovidVaccinations$ vcc
on dth.location = vcc.location and dth.date = vcc.date
where dth.continent is not null

select *, (PeopleVaccinated/population)*100 
 from #PercentPopulationVaccinated

 -- Let's create View to store data for later visualization

 create view PercentPopulationVaccinated as
select dth.continent, dth.location, dth.date, dth.population, vcc.new_vaccinations, 
SUM(CONVERT(int,vcc.new_vaccinations)) OVER (Partition by dth.location order by dth.location, dth.date) as PeopleVaccinated
from CovidDeaths$ dth join CovidVaccinations$ vcc
on dth.location = vcc.location and dth.date = vcc.date
where dth.continent is not null

select *
from  PercentPopulationVaccinated











