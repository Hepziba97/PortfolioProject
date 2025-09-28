
SELECT Location, date, new_tests, total_tests
FROM PortfolioProject..CovidVaccinations
ORDER BY 3, 4;

--Total Cases vs Total Deaths
--Showing likelihood of dying if you contact covid in your country.
select Location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100, 2) AS percentage_death
from PortfolioProject..CovidDeaths
where Location = 'Lesotho' or Location like '%africa%'
order by 1, 2

--Total Cases vs Population
--Shows percentage of population with covid
select Location, date, population, total_cases, round((total_cases/population)*100, 2) AS PercentagePopulationInfected
from PortfolioProject..CovidDeaths
--where Location = 'Lesotho' or Location like '%africa%'
order by 1, 2

--Countries with the Highest infection rate as compared to Population
select Location, population, max(total_cases) as HighestInfectionCount, 
max(round((total_cases/population)*100, 2)) AS PercentagePopulationInfected
from PortfolioProject..CovidDeaths
group by location, population
order by percentagePopulationInfected desc

--Countries with Highest Death count per Population
select Location, max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
where Continent is not null
group by Location
order by HighestDeathCount desc

--Continent with Highest death count per population
select continent, max(cast (total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where Continent is not null
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, 
sum(cast(new_deaths as int)) / sum(new_cases)*100 as PercentageDeath
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1, 2

select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, 
sum(cast(new_deaths as int)) / sum(new_cases)*100 as PercentageDeath
from PortfolioProject..CovidDeaths
where continent is not null
order by 1, 2


select cda.continent, cda.location, cda.date, cda.population, cva.new_vaccinations
from PortfolioProject..CovidDeaths as cda
join PortfolioProject..CovidVaccinations as cva
	on cda.location = cva.location 
	and cda.date = cva.date
where cda.continent is not null
order by 1, 2, 3

-- USING CTE
With Popvsvac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
as 
(
Select cda.continent, cda.location, cda.date, cda.population, cva.new_vaccinations
, sum(convert(int, cva.new_vaccinations)) over(Partition by cda.location, cda.date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths cda
join PortfolioProject..CovidVaccinations cva
	on cda.location = cva.location
	and cda.date = cva.date
where cda.continent is not null
)

select *, (RollingPeopleVaccinated/Population)*100
from Popvsvac

---TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
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
Select cda.continent, cda.location, cda.date, cda.population, cva.new_vaccinations
, sum(convert(int, cva.new_vaccinations)) over(Partition by cda.location, cda.date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths cda
join PortfolioProject..CovidVaccinations cva
	on cda.location = cva.location
	and cda.date = cva.date
where cda.continent is not null


select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

Create View PercentPopulationVaccinated as
Select cda.continent, cda.location, cda.date, cda.population, cva.new_vaccinations
, sum(convert(int, cva.new_vaccinations)) over(Partition by cda.location, cda.date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths cda
join PortfolioProject..CovidVaccinations cva
	on cda.location = cva.location
	and cda.date = cva.date
where cda.continent is not null

select *
from PercentPopulationVaccinated