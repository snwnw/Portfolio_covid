Select *
From PortfolioProject..['Covid Deaths']
order by 3,4

Select *
From PortfolioProject..['Covid Vaccinations']
order by 3,4


Select location, date, total_cases, new_cases, total_deaths, population 
From PortfolioProject..['Covid Deaths']
order by 1,2

Select location, date, total_cases, total_deaths,  (CAST(total_deaths AS float) / CAST(total_cases AS float)) * 100 AS DeathPercentage
From PortfolioProject..['Covid Deaths']
order by 1,2
-- Изменение типа данных столбца total_cases и total_deaths на int
ALTER TABLE PortfolioProject..['Covid Deaths']
ALTER COLUMN total_cases int;
ALTER TABLE PortfolioProject..['Covid Deaths']
ALTER COLUMN total_deaths int;


Select location, date, Population,total_cases, (total_cases/ population) * 100 AS CovidPercentage
From PortfolioProject..['Covid Deaths']
--Where location = 'United States'
order by 1,2

Select location, Population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/ population)) * 100 AS CovidPercentage
From PortfolioProject..['Covid Deaths']
Group by location, Population
order by 4 desc

Select location, Population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/ population)) * 100 AS CovidPercentage
From PortfolioProject..['Covid Deaths']
Group by location, Population
order by 4 desc

Select location, Population,MAX(total_deaths) as HighestDeathCount, MAX((total_deaths/ population)) * 100 AS DiedPercentage
From PortfolioProject..['Covid Deaths']
where continent is not NULL
Group by location, Population
order by 2 desc

Select *
From PortfolioProject..['Covid Deaths']
where continent is not NULL
order by 3,4


Select location, Population,MAX(total_deaths) as HighestDeathCount, MAX((total_deaths/ population)) * 100 AS DiedPercentage
From PortfolioProject..['Covid Deaths']
where continent is not NULL
Group by location, Population
order by 3 desc

Select date, MAX(total_deaths) as HighestDeathCount, MAX((total_deaths/ population)) * 100 AS DiedPercentage
From PortfolioProject..['Covid Deaths']
where continent is not NULL
Group by continent
order by 3 desc



Select SUM(new_cases) as TotalNewCases, SUM(new_deaths) as TotalNewDeaths, 
CASE
        WHEN SUM(new_cases) = 0 THEN NULL
        ELSE (SUM(new_deaths) * 100.0) / NULLIF(SUM(new_cases), 0)
    END AS DeathPercentage
From PortfolioProject..['Covid Deaths']
Where continent is not NULL
--Group by date
order by 1,2

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.Location, dea.date ) as RollingPeopleVaccinated
From PortfolioProject..['Covid Deaths'] as dea
Join PortfolioProject..['Covid Vaccinations'] as vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not NULL
	order by 2,3 	

	With PopvsVac (Continent, location, date, population,new_vaccinations,RollingPeopleVaccinated)
	as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.Location, dea.date ) as RollingPeopleVaccinated
From PortfolioProject..['Covid Deaths'] as dea
Join PortfolioProject..['Covid Vaccinations'] as vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not NULL
	)
	Select *, (RollingPeopleVaccinated/population)*100 as PercentageOfPeopleVac
	From PopvsVac


	Create table #PercentPopulationVaccinated
	(
	Continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	RollingPeopleVaccinated numeric
	)
	insert into #PercentPopulationVaccinated
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.Location, dea.date ) as RollingPeopleVaccinated
From PortfolioProject..['Covid Deaths'] as dea
Join PortfolioProject..['Covid Vaccinations'] as vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not NULL

Select *, (RollingPeopleVaccinated/population)*100 as PercentageOfPeopleVac
	From #PercentPopulationVaccinated


	create view PercentPopulationVaccinated as 
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.Location, dea.date ) as RollingPeopleVaccinated
From PortfolioProject..['Covid Deaths'] as dea
Join PortfolioProject..['Covid Vaccinations'] as vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not NULL
	
	select * 
	from PercentPopulationVaccinated