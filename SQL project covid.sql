SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths cd 
order by 1,2

-- looking at totall cases vs total death
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathrate
FROM CovidDeaths cd
order by 1,2

-- show the death percentage of population
SELECT location, date, total_cases, total_deaths, (total_deaths/population)*100 as DeathRateByPopulation
From CovidDeaths cd
order by 1,2

-- looking at countries with highest infected rate
SELECT location, population, max(total_cases), max((total_cases/population)*100) as PercentPopulationInfected
from CovidDeaths cd 
group by location ,population 
ORDER BY PercentPopulationInfected DESC

-- showing countries with highest death count per population
select location, population, max(total_deaths) as TotalDeathCount, max((total_deaths/population)*100) as DeathRateCount
from CovidDeaths cd 
where continent is not NULL
group by location , population 
order by DeathRateCount desc


-- Breakdown death by Continents
SELECT continent, max(total_deaths) as TotalDeathCount
FROM CovidDeaths cd 
WHERE continent is not null
Group by continent 
order by TotalDeathCount DESC 

-- Global Numbers
select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths , (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
FROM CovidDeaths cd 
WHERE continent is not null


-- Looking at total population vs vaccination
WITH PopVsVac (continent, location, date, population, New_vaccinations, RollingPeopleVaccinated) as (
SELECT cd.continent, cd.location, cd.population , cv.new_vaccinations , 
sum(vac.new_vaccinations) over (PARTITION by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated,
FROM CovidDeaths cd 
join CovidVaccine cv 
on cd.location = cv.location 
and cd.`date` = cv.`date`
where dea.continent is not NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100
From PopVsVac

-- USE CTE
WITH popvsVac (Continet, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) as
(
Select dea.continent , dea.location , dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
join CovidVaccine vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL
order by 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 as PercentageOfVaccination
FROM popvsVac

-- creating view to store data for latter
create view PercentPopulationVaccinated as
Select dea.continent , dea.location , dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
join CovidVaccine vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL


