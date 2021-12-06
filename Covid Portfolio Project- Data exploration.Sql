Select* 
from dbo.CovidDeaths$
Order by 3,4
Select*
from dbo.CovidVaccinations$
Order by 3,4

Select location, date, total_cases, new_cases, total_deaths,population
from dbo.CovidDeaths$
Order by 1,2

--Looking at Total cases vs total deaths
Select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from dbo.CovidDeaths$
where location like '%states%'
Order by 1,2

--Looking at Total cases vs Population

Select location, date, total_cases, Population,(total_cases/population)*100 as Infectionrate
from dbo.CovidDeaths$
where location like '%states%'
Order by 1,2

--Looking at countries with highest Infection rate compared to the Population


Select location, MAX (total_cases) as HighestInfectioncount, Population, MAX((total_cases/population))*100 as Infectionrate
from dbo.CovidDeaths$
--where location like '%states%'
Group by location,Population
Order by Infectionrate desc


--Looking at countries with highest Death rates .

Select Location, MAX (cast(total_deaths as integer)) as TotalDeathCount
from dbo.CovidDeaths$
where continent is not null
Group by location
Order by TotalDeathCount desc

--Let's break down by continent

Select continent, MAX (cast(total_deaths as integer)) as TotalDeathCount
from dbo.CovidDeaths$
where continent is not null
Group by continent
Order by TotalDeathCount desc


--Global Numbers



Select* 
from dbo.CovidVaccinations$

Select*
from dbo.CovidDeaths$ dea
JOIN dbo.CovidVaccinations$ vac
ON dea.location = vac.location
and dea.date = vac.date


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from dbo.CovidDeaths$ dea
JOIN dbo.CovidVaccinations$ vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL
order by 2,3



Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
 from dbo.CovidDeaths$ dea
JOIN dbo.CovidVaccinations$ vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL
order by 2,3



--USE CTE

With PopvsVac(Continent, Location, date, Population,new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
 from dbo.CovidDeaths$ dea
JOIN dbo.CovidVaccinations$ vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL
--order by 2,3
)
Select*,(RollingPeopleVaccinated/Population)*100
from PopvsVac



--TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from dbo.CovidDeaths$ dea
JOIN dbo.CovidVaccinations$ vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL;

Select*,(RollingPeopleVaccinated/Population)*100
from
#PercentPopulationVaccinated




--Creating view to store data for visualization

 Create view PercentPopulationVaccinated as
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
 from dbo.CovidDeaths$ dea
JOIN dbo.CovidVaccinations$ vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL
--order by 2,3


Select* 
from PercentPopulationVaccinated
