Select *
From PortfolioProject..CovidDeaths
WHERE Continent is not null
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

-- Select Data we are going to be using

Select Location, Date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
WHERE Continent is not null
Order by 1,2

-- Looking at Total_Cases vs Total_Deaths
-- Show's death rate if you are infected by COVID19 in the UK

Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
WHERE Location like '%kingdom%%'
and Continent is not null
Order by 1,2

-- Looking at Total Cases vs Population
-- Shows Percentage of population that has COVID

Select Location, Date, Population, total_cases, (total_cases/population)*100 AS TotalCasesPerPopulation 
From PortfolioProject..CovidDeaths
WHERE Location like '%kingdom%%'
Order by 1,2

-- Looking at Countries with Highest Infection rate compared to Population

Select Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS TotalCasesPerPopulation
From PortfolioProject..CovidDeaths
--WHERE Location like '%kingdom%%'
GROUP BY Location, population
Order by TotalCasesPerPopulation desc

-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
--WHERE Location like '%kingdom%%'
WHERE Continent is not null
GROUP BY Location
Order by TotalDeathCount desc

-- Let's break things down by continent
-- Showing Continents with the highest death count per population

Select location, MAX(cast(Total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
--WHERE Location like '%kingdom%%'
WHERE continent is null
GROUP BY location
Order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
--WHERE Location like '%kingdom%%'
WHERE Continent is not null
--Group by date
Order by 1,2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingVaccinationRate
--, (RollingVaccinationRate/population)*100
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null
Order by 2,3

--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinationRate)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingVaccinationRate
--, (RollingVaccinationRate/population)*100
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null
--Order by 2,3
)
Select *, (RollingVaccinationRate/Population)*100
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
RollingVaccinationRate numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingVaccinationRate
--, (RollingVaccinationRate/population)*100
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null

Select *, (RollingVaccinationRate/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualisations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingVaccinationRate
--, (RollingVaccinationRate/population)*100
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated