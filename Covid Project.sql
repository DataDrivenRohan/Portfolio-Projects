Select*
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select*
--From PortfolioProject..CovidVac
--order by 3,4

-- Select Data that we are going to be using --
Select location, date, total_cases,new_cases,total_deaths,population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2	

-- Looking at Total Cases Vs Total Death--
-- Shows likelihood of dying if you contract covid in the specified country--
Select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as MortalityRate
From PortfolioProject..CovidDeaths
Where location like '%states%' and continent is not null
order by 1,2

--Looking at Countries with the highest Mortality rate compared to population--
	Select location,MAX(try_cast(total_deaths as int)) as TotalDeathCount,population,MAX((total_deaths/population))*100 as PercentageDead
	From PortfolioProject..CovidDeaths
	Where continent is not null
	Group by location, population
	order by TotalDeathCount desc

--Looking at the Total Cases VS the Population--
--Shows what perecentage of people got covid in the specified country
Select location, date, total_cases,population,(total_cases/population)*100 as InfectedRate
From PortfolioProject..CovidDeaths
Where location like '%states%' and continent is not null
order by 1,2

--Looking at Countries with the highest Infection rate compared to population--
	Select location,MAX(total_cases) as HighestInfectionCount,population,MAX((total_cases/population))*100 as PercentageInfected
	From PortfolioProject..CovidDeaths
	Where continent is not null
	Group by location, population
	order by PercentageInfected desc

--LET'S BREAK THINGS DOWN BY CONTINENT --
--Looking at Countries with the highest Mortality rate compared to population--
	Select Location,MAX(try_cast(total_deaths as int)) as TotalDeathCount
	From PortfolioProject..CovidDeaths
	Where continent is null
	Group by location
	order by TotalDeathCount desc

	Select continent,MAX(try_cast(total_deaths as int)) as TotalDeathCount
	From PortfolioProject..CovidDeaths
	Where continent is not null
	Group by continent
	order by TotalDeathCount desc

-- ADD THE REST HERE --

--Global Numbers--
--By Date-
Select date, SUM(new_cases) as total_cases , SUM(try_cast(new_deaths as int))as total_deaths,SUM(try_cast(new_deaths as int))/SUM(New_Cases)*100 as Death_percentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
order by Death_percentage Desc

--Total--
Select SUM(new_cases) as total_cases , SUM(try_cast(new_deaths as int))as total_deaths,SUM(try_cast(new_deaths as int))/SUM(New_Cases)*100 as Death_percentage
From PortfolioProject..CovidDeaths
Where continent is not null
order by Death_percentage Desc


--Looking at total population vs Vaccinations

Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVAC vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 1,2,3

Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
--,(Rolling_People_Vaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVAC vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--USE CTE
With PopvsVac (Continent,Location,Date, Population,new_vaccinations, Rolling_People_Vaccinated)
as
(
Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
--,(Rolling_People_Vaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVAC vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select*,(Rolling_People_Vaccinated/Population)*100 as Percentage_Of_People_Vaccinated
From PopvsVac
order by 7 desc

--TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
	Create Table #PercentPopulationVaccinated
	(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	Rolling_People_Vaccinated numeric
	)

	Insert into #PercentPopulationVaccinated
	Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
	SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
	--,(Rolling_People_Vaccinated/population)*100
	From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVAC vac
	on dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
	--order by 2,3
	Select*,(Rolling_People_Vaccinated/Population)*100 as Percentage_Of_People_Vaccinated
	From #PercentPopulationVaccinated

	--Creating View to store data for later visualizations

	Create View PercentPopulationVaccinated as
	Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
	SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
	--,(Rolling_People_Vaccinated/population)*100
	From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVAC vac
	on dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
	--order by 2,3

	select* 
	from PercentPopulationVaccinated

	









	
		

