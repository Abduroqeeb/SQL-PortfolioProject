SELECT *
from PortfolioProject..CovidDeaths$
where continent is not null
ORDER BY 3,4

--SELECT *
--from PortfolioProject..CovidVaccinations$
--ORDER BY 3,4



SELECT location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
order by 1,2

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
WHERE location like 'Nigeria'
order by 1,2


--TOTAL CASES VS POPULAIONS


SELECT location, date, total_cases, population, (total_deaths/population)*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths$
--WHERE location like 'Nigeria'
order by 1,2

SELECT location, date, total_cases, population, (total_deaths/population)*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths$
WHERE location like 'Nigeria'
order by 1,2

--HIGHEST INFECTION COUNTRY RATE COMPARED TO POPLATION

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as 
   PercentagePopulationInfected
from PortfolioProject..CovidDeaths$
Group by location, population
order by PercentagePopulationInfected desc

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as 
   PercentagePopulationInfected
from PortfolioProject..CovidDeaths$
WHERE location like 'Nigeria'
Group by location, population
order by PercentagePopulationInfected desc


--COUNTRY WITH HIGHEST DEATH COUNT PER POPULATION

SELECT location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--WHERE location like 'Nigeria'
where continent is not null
Group by location
order by TotalDeathCount desc

--BREAKING IT DOWN BY CONTINENT WITH HIGHEST DEATH COUNT

SELECT continent, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--WHERE location like 'Nigeria'
where continent is NOT null
Group by continent
order by TotalDeathCount desc



SELECT date, SUM(new_cases) as Total_cases, SUM(CAST(new_deaths as int))as  Total_Death, SUM(cast
(new_deaths as int)),SUM(New_Cases)*100 as Deathpercentage
from PortfolioProject..CovidDeaths$
where continent is not null
group by date
order by 1,2


--TOTAL POPULATION VS VACCINATIONS

SELECT * 
FROM PortfolioProject..CovidDeaths$  DEA
JOIN PortfolioProject..CovidVaccinations$ VAC
  ON DEA.location = VAC.location
  AND DEA.date = VAC.date


 

  SELECT DEA.continent, DEA.location,DEA.date,DEA.population, VAC.new_vaccinations,
  SUM(cast(VAC.new_vaccinations as int)) OVER (partition by DEA.location)
FROM PortfolioProject..CovidDeaths$  DEA
JOIN PortfolioProject..CovidVaccinations$ VAC
  ON DEA.location = VAC.location
  AND DEA.date = VAC.date
  WHERE DEA.continent IS NOT NULL
  ORDER BY 1,2,3


  SELECT DEA.continent, DEA.location,DEA.date,DEA.population, VAC.new_vaccinations,
  SUM(convert(int, VAC.new_vaccinations)) OVER (partition by DEA.location order by DEA.location, DEA.Date) as PeopleVaccinated
FROM PortfolioProject..CovidDeaths$  DEA
JOIN PortfolioProject..CovidVaccinations$ VAC
  ON DEA.location = VAC.location
  AND DEA.date = VAC.date
  WHERE DEA.continent IS NOT NULL
  ORDER BY 2,3


 --USING CTE
 WITH PopvsVac (Continent, location, Date, population,new_vaccinations, PeopleVaccinated)
 AS  
 (SELECT DEA.continent, DEA.location,DEA.date,DEA.population, VAC.new_vaccinations,
  SUM(convert(int, VAC.new_vaccinations)) OVER (partition by DEA.location order by DEA.location, DEA.Date) as PeopleVaccinated
FROM PortfolioProject..CovidDeaths$  DEA
JOIN PortfolioProject..CovidVaccinations$ VAC
  ON DEA.location = VAC.location
  AND DEA.date = VAC.date
  WHERE DEA.continent IS NOT NULL
  --ORDER BY 2,3
  )

  --select *
  --from PopvsVac

  Select *, 
  (PeopleVaccinated/population)*100 AS PercentageVaccinated
  from PopvsVac 

  --TEMP TABLE
  DROP Table if exists #PercentageVaccinated
  create table #PercentPopulationVaccinated
  (
  Continent nvarchar (255),
  Location nvarchar (255),
  Date datetime,
  population numeric,
  New_vaccinations numeric,
  PeopleVaccinated numeric
  )




  insert into #PercentPopulationVaccinated
  SELECT DEA.continent, DEA.location,DEA.date,DEA.population, VAC.new_vaccinations,
  SUM(convert(int, VAC.new_vaccinations)) OVER (partition by DEA.location order by DEA.location, DEA.Date) as PeopleVaccinated
FROM PortfolioProject..CovidDeaths$  DEA
JOIN PortfolioProject..CovidVaccinations$ VAC
  ON DEA.location = VAC.location
  AND DEA.date = VAC.date
  WHERE DEA.continent IS NOT NULL
  --ORDER BY 2,3

  Select *, 
  (PeopleVaccinated/population)*100 
  from #PercentPopulationVaccinated


   --creating  VIEW FOR VISUALIZATION

   CREATE VIEW PercentPopulationVaccinated AS
   SELECT DEA.continent, DEA.location,DEA.date,DEA.population, VAC.new_vaccinations,
  SUM(convert(int, VAC.new_vaccinations)) OVER (partition by DEA.location order by DEA.location, DEA.Date) as PeopleVaccinated
FROM PortfolioProject..CovidDeaths$  DEA
JOIN PortfolioProject..CovidVaccinations$ VAC
  ON DEA.location = VAC.location
  AND DEA.date = VAC.date
  WHERE DEA.continent IS NOT NULL
  --ORDER BY 2,3

  SELECT *
  FROM PercentPopulationVaccinated