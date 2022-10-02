Select *
from Portpolio_Project_01..covid_death
where continent is not null
order by 3,4

--Select *
--from Portpolio_Project_01..vaccination
--order by 3,4

-- Select data that we are going to use
Select location,date,total_cases,new_cases,total_deaths,population
from Portpolio_Project_01..covid_death
where continent is not null
order by 1,2

-- looking at total cases vs total deaths
-- showing likelihood of dying if you contract covid in your country
Select location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from Portpolio_Project_01..covid_death
where location like '%states%'
and continent is not null
order by 1,2

-- Looking total cases vs population
--Show the percentage of population done covid
Select location,date,total_cases,new_cases,(total_cases/population)*100 as PerseentagePopulationInfected
from Portpolio_Project_01..covid_death
--where location like '%states%'
order by 1,2

-- Looking at highest Infected rate compare to population
Select location,population,max(total_cases) as HighestInfactionCount,max((total_cases/population))*100 as 
PerseentagePopulationInfected
from Portpolio_Project_01..covid_death
--where location like '%states%'
group by location,population
order by PerseentagePopulationInfected desc

-- showing the population with highest death count per population
Select location,max(cast (total_deaths as int)) as TotalDeathCount
from Portpolio_Project_01..covid_death
--where location like '%states%'
where continent is not null
group by location,population
order by TotalDeathCount desc

-- Let's break things down by continent
Select continent,max(cast (total_deaths as int)) as TotalDeathCount
from Portpolio_Project_01..covid_death
where continent is not null
group by continent
order by TotalDeathCount desc

--Showing Continents with the highest death count per population
Select continent,max(cast (total_deaths as int)) as TotalDeathCount
from Portpolio_Project_01..covid_death
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Number
Select sum(new_cases) as TotalNewCase , sum(cast(new_deaths as int)) as TotalNewDeathCases ,(sum(cast(new_deaths as int))/sum(total_cases))*100 as DeathPercentage
from Portpolio_Project_01..covid_death
--where location like '%states%'
where continent is not null
--group by date
order by 1,2



--JOIN 2 TABLE
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from Portpolio_Project_01..covid_death dea
join Portpolio_Project_01..vaccination vac
  on dea.location=vac.location
  and dea.date=vac.date
where dea.continent is not null
order by 2,3


with PopvsVacc (continent,location,date,population,new_vaccination,RollingPeopleVaccinated)
as(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from Portpolio_Project_01..covid_death dea
join Portpolio_Project_01..vaccination vac
  on dea.location=vac.location
  and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select * ,(RollingPeopleVaccinated/population)*100 as RollingPeoplePercentage
from
PopvsVacc


--TEMP TABLE
DROP table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from Portpolio_Project_01..covid_death dea
join Portpolio_Project_01..vaccination vac
  on dea.location=vac.location
  and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select * --,(RollingPeopleVaccinated/population)*100  as RollingPeoplePercentage
from #PercentPopulationVaccinated


DROP  table if exists PercentPopulationVaccinated

--Creating view to store the data for later visualization
create view PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from Portpolio_Project_01..covid_death dea
join Portpolio_Project_01..vaccination vac
  on dea.location=vac.location
  and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select * from
PercentPopulationVaccinated
