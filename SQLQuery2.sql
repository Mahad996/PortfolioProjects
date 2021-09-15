Select * 
From PortfolioProject..['Covid deaths']
Where continent is not null
order by 3,4 

--Select * 
--From PortfolioProject..['Covid Vaccinations']
--Order by 3,4 

-- Selecting the data that I'll be using for the project.

Select Location, Date, total_cases, new_cases, total_deaths, population 
From PortfolioProject..['Covid deaths']
order by 1,2 

-- The total cases in comparison to the total deaths

Select Location, Date, total_cases, total_deaths, ((total_Deaths/total_cases)*100) as Deathpercentage
From PortfolioProject..['Covid deaths']
Where Location like '%United kingdom%'
order by 1,2 

-- The total cases in comparison to the population size

Select Location, Date,population, total_cases, ((total_cases/population)*100) as CovidInfectedpercentage
From PortfolioProject..['Covid deaths']
Where Location like '%United kingdom%'
order by 1,2 

--What countries have the highest population rates in respect to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, ((MAX(total_cases)/population)*100) as Covidpercentage
From PortfolioProject..['Covid deaths']
Group by Location, Population
order by Covidpercentage desc

-- What countries had the highest death count in respect to population

Select Location, MAX(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['Covid deaths']
Where continent is not null
Group by Location
order by TotalDeathCount desc

--Continental breakdown

Select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['Covid deaths']
Where continent is not null
Group by Continent
order by TotalDeathCount desc

-- What are the Global numbers?

Select SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, SUM(CAST(New_deaths as int))/SUM(new_cases)*100 as Deathpercentage
From PortfolioProject..['Covid deaths']
Where continent is not null 
order by 1,2 

--Joining the vaccination table with the Death table

Select * 
From Portfolioproject..['Covid deaths'] a
Join Portfolioproject..['Covid Vaccinations'] b
on  a.location = b.location
and a.date = b.date

--Total population in respect to Vaccinations

Select a.continent, a.location, a.date, a.population, b.new_vaccinations, SUM(CONVERT(INT,b.new_vaccinations)) OVER (Partition by a.location order by a.location, a.date) as VaccinationCounter 
From Portfolioproject..['Covid deaths'] a
Join Portfolioproject..['Covid Vaccinations'] b
on  a.location = b.location
and a.date = b.date
Where a.continent is not null
order by 2,3

-- CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, VaccinationCounter)
as (
Select a.continent, a.location, a.date, a.population, b.new_vaccinations, SUM(CONVERT(INT,b.new_vaccinations)) OVER (Partition by a.location order by a.location, a.date) as VaccinationCounter 
From Portfolioproject..['Covid deaths'] a
Join Portfolioproject..['Covid Vaccinations'] b
on  a.location = b.location
and a.date = b.date
Where a.continent is not null)

Select *, (VaccinationCounter/Population)*100
From PopvsVac

-- Temporary table

DROP table if exists #Populationvaccinatedpercentage
Create table #Populationvaccinatedpercentage
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Vaccinationcounter numeric
)

Insert into #Populationvaccinatedpercentage
Select a.continent, a.location, a.date, a.population, b.new_vaccinations, SUM(CONVERT(BIGINT,b.new_vaccinations)) OVER (Partition by a.location order by a.location, a.date) as VaccinationCounter 
From Portfolioproject..['Covid deaths'] a
Join Portfolioproject..['Covid Vaccinations'] b
on  a.location = b.location
and a.date = b.date
--Where a.continent is not null

Select *, (VaccinationCounter/Population)*100
From #Populationvaccinatedpercentage

 
 -- Storing data for visualisation

Create view Populationvaccinatedpercentage as
Select a.continent, a.location, a.date, a.population, b.new_vaccinations, 
SUM(CONVERT(BIGINT,b.new_vaccinations)) OVER (Partition by a.location order by a.location, a.date) as VaccinationCounter 
From Portfolioproject..['Covid deaths'] a
Join Portfolioproject..['Covid Vaccinations'] b
on  a.location = b.location
and a.date = b.date
Where a.continent is not null

Select * from Populationvaccinatedpercentage