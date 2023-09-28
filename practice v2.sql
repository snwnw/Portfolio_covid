--At the beginning, I needed to load the database into SQL Server, where I encountered the problem **The 'Microsoft.ACE.OLEDB.16.0' provider is not registered on the local machine. (System.Data)**, which I was able to solve by installing the 32-bit version of accessdatabaseengine on top of the 64-bit version of SQL Server using the cmd parameter **/quiet**, because otherwise an interactive window appears that does not allow the installation of the 32-bit version.

--In total, there are 343,307 rows in the database.
--After importing, we check if everything is in order by applying sorting.

sql
Select *
From PortfolioProject..['Covid Deaths']
order by 3,4


```sql
Select *
From PortfolioProject..['Covid Vaccinations']
order by 3,4

```

--Make the code a comment.
--Then, create a new query that selects only the columns of interest with sorting by location and date.

```sql
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..['Covid Deaths']
order by 1,2

```

--Next, let's look at the ratio of total deaths to total cases.

```sql
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..['Covid Deaths']
order by 1,2

```

--At this stage, I encountered the error *Operand data type nvarchar is invalid for divide operator.*
--We need to change the data type to a floating-point number.

```sql
Select location, date, total_cases, total_deaths, (CAST(total_deaths AS float) / CAST(total_cases AS float)) * 100 AS DeathPercentage
From PortfolioProject..['Covid Deaths']
order by 1,2

```

--After ensuring that everything works in the query results, I changed the data types of the table columns.

```sql
-- Change the data type of the total_cases and total_deaths columns to int
ALTER TABLE PortfolioProject..['Covid Deaths']
ALTER COLUMN total_cases int;
ALTER TABLE PortfolioProject..['Covid Deaths']
ALTER COLUMN total_deaths int;

```

--Write the query again with the correct data types, filtering the rows by location that contains "states". This is because in addition to **United States**, we have **United States Virgin Islands** in the location.

```sql
Select location, date, total_cases, total_deaths, (total_deaths/ total_cases) * 100 AS DeathPercentage
From PortfolioProject..['Covid Deaths']
Where location like '%states%'
order by 1,2

```

--Let's see the percentage of cases compared to the population in the United States.

```sql
Select location, date, Population,total_cases, (total_cases/ population) * 100 AS CovidPercentage
From PortfolioProject..['Covid Deaths']
Where location = 'United States'
order by 1,2

```

--Let's see the percentage of cases compared to the population in all countries.

```sql
Select location, date, Population,total_cases, (total_cases/ population) * 100 AS CovidPercentage
From PortfolioProject..['Covid Deaths']
order by 1,2

```

--Find the highest infection rate among the population.

```sql
Select location, Population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/ population)) * 100 AS CovidPercentage
From PortfolioProject..['Covid Deaths']
Group by location, Population
order by 4 desc

```

--Add the percentage of deaths among the population and sort by population count.

```sql
Select location, Population,MAX(total_deaths) as HighestDeathCount, MAX((total_deaths/ population)) * 100 AS DiedPercentage
From PortfolioProject..['Covid Deaths']
Group by location, Population
order by 2 desc

```

--While executing the above code, it was found that the location column contains combined data for parts of the world, such as World, Asia, etc., which need to be removed. Let's run the code again to see what's going on:

```sql
Select *
From PortfolioProject..['Covid Deaths']
order by 3,4

```

--The reason is the presence of NULL in the continent column, so let's remove these rows from the output and check again.

```sql
Select *
From PortfolioProject..['Covid Deaths']
where continent is not NULL
order by 3,4

```

--Run the code again, this time without NULL in the continent column.

```sql
Select location, Population,MAX(total_deaths) as HighestDeathCount, MAX((total_deaths/ population)) * 100 AS DiedPercentage
From PortfolioProject..['Covid Deaths']
where continent is not NULL
Group by location, Population
order by 2 desc

```

--Let's look at the breakdown by continents.

```sql
Select continent,MAX(total_deaths) as HighestDeathCount, MAX((total_deaths/ population)) * 100 AS DiedPercentage
From PortfolioProject..['Covid Deaths']
where continent is not NULL
Group by continent
order by 3 desc

```

--Next, find the number of new cases worldwide with a breakdown by dates.

```sql
Select date,SUM(new_cases)
From PortfolioProject..['Covid Deaths']
Where continent is not NULL
Group by date
order by 1,2

```

--Let's see the percentage of deaths compared to the number of daily infections worldwide. Since division by zero occurs, we will add a check for zero.

```sql
Select date, SUM(new_cases) as TotalNewCases, SUM(new_deaths) as TotalNewDeaths,
CASE
WHEN SUM(new_cases) = 0 THEN NULL
ELSE (SUM(new_deaths) * 100.0) / NULLIF(SUM(new_cases), 0)
END AS DeathPercentage
From PortfolioProject..['Covid Deaths']
Where continent is not NULL
Group by date
order by 1,2

```

--We can also look at the overall number of infections and deaths without daily breakdown to see their ratio.

```sql
Select SUM(new_cases) as TotalNewCases, SUM(new_deaths) as TotalNewDeaths,
CASE
WHEN SUM(new_cases) = 0 THEN NULL
ELSE (SUM(new_deaths) * 100.0) / NULLIF(SUM(new_cases), 0)
END AS DeathPercentage
From PortfolioProject..['Covid Deaths']
Where continent is not NULL
order by 1,2

```

--Join the two tables and see the number of new vaccinations.

```sql
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..['Covid Deaths'] as dea
Join PortfolioProject..['Covid Vaccinations'] as vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not NULL
order by 2,3

```

--Add a column that allows us to see the cumulative number of vaccinated people compared to the previous day. *I used the Bigint data type because using INT gave an error about the value being too large.*

```sql
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.Location, dea.date ) as RollingPeopleVaccinated
From PortfolioProject..['Covid Deaths'] as dea
Join PortfolioProject..['Covid Vaccinations'] as vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not NULL
order by 2,3

```

--Create a temporary table.

```sql
With PopvsVac (Continent, location, date, population,new_vaccinations,RollingPeopleVaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.Location, dea.date ) as RollingPeopleVaccinated
From PortfolioProject..['Covid Deaths'] as dea
Join PortfolioProject..['Covid Vaccinations'] as vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not NULL
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

```

--Alternatively, we can create a temporary table using a different method.

```sql
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

```

```sql
Select *, (RollingPeopleVaccinated/population)*100 as PercentageOfPeopleVac
From #PercentPopulationVaccinated

```

--Create a view to store the data for future visualization.

```sql
create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.Location, dea.date ) as RollingPeopleVaccinated
From PortfolioProject..['Covid Deaths'] as dea
Join PortfolioProject..['Covid Vaccinations'] as vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not NULL

```
