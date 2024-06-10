Select *
FROM PortfolioProject..[covid_deaths]
where continent is not null
order by 3,4

--Change the table (total_cases) from 'varchar' to 'float'
--ALTER TABLE PortfolioProject..[covid_data]
--ALTER COLUMN total_cases FLOAT;

--Change the table (total_deaths) from 'varchar' to 'float'
--ALTER TABLE PortfolioProject..[covid_data]
--ALTER COLUMN total_deaths FLOAT;

-- Select data that we are going to be using

	-- Looking at Total Cases vs Total Deaths
	-- Shows likelihood  of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
	From PortfolioProject..[covid_deaths]
	Where location like '%states'
	and continent is not null
	order by 1,2 

-- Looking at Total Cases vs Population
Select Location, date, Population, (total_cases/population)*100 as PercentPopulationInfected
	From PortfolioProject..[covid_deaths]
--Where location like '%states'
where continent is not null
	order by 4 desc

	-- Looking at countries with Highest Infection Rate compared to Population
Select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as 
		PercentPopulationInfected
	From PortfolioProject..[covid_deaths]
--Where location like '%andorra'
where continent is not null
Group by location, population
	order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population
Select location, MAX(cast(total_deaths as int)) AS TotalDeathCount
	From PortfolioProject..[covid_deaths]
where continent is not null
Group by location
	order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population
Select location, MAX(cast(total_deaths as int)) AS TotalDeathCount
	From PortfolioProject..[covid_deaths]
	--where location like '%states%'
where continent is null
Group by location
	order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM
(new_cases)*100 as DeathPercentage
	From PortfolioProject..[covid_deaths]
	--Where location like '%states'
	WHERE continent is not null
	--GROUP BY date
	order by 1,2 

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..covid_deaths dea
JOIN PortfolioProject..covid_vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

With PopsVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..covid_deaths dea
JOIN PortfolioProject..covid_vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select*, (RollingPeopleVaccinated/population)*100
FROM PopsVsVac

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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..covid_deaths dea
JOIN PortfolioProject..covid_vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
Select*, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..covid_deaths dea
JOIN PortfolioProject..covid_vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
FROM PercentPopulationVaccinated