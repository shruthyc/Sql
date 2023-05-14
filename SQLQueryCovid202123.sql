Select * from ProjectPortfolio..CovidDeaths
where continent is not null
Order By 3,4

Select * from ProjectPortfolio..CovidVaccinations
Order By 3,4

----Selecting data's I need to work with

Select Location,Date, total_cases, new_cases, total_deaths, population from ProjectPortfolio..CovidDeaths
where continent is not null
order by 1,2

------Calculating Death Percentage in Various Countries

Select Location,Date, total_cases, total_deaths, (cast (total_deaths as float)/cast (total_cases as float))*100 as PercentageOfDeaths  from ProjectPortfolio..CovidDeaths
where location like '%India%'
and continent is not null
order by 1,2

-------Calculating total cases vs populations

Select Location,Date, total_cases, Population, (cast (total_cases as float)/population)*100 as PopulationAffected  from ProjectPortfolio..CovidDeaths
where location like '%India%'
order by 1,2

----Countries with highest infected rate compared to population

Select Location, Population,  Max (cast (total_cases as float)) as HighestInfectionCount, Max((cast (total_cases as float))/population)*100 as PopulationAffected  from ProjectPortfolio..CovidDeaths
---where location like '%India%'
Group By Location,population
order by PopulationAffected desc


-----Countries with highest death count per population
select Location, Max (cast (total_deaths as int)) as TotalDeathCount from ProjectPortfolio..CovidDeaths
where continent is not null
Group By Location
order by TotalDeathCount desc

------Total death counts according to continents

select continent, Max (cast (total_deaths as int)) as TotalDeathCount from ProjectPortfolio..CovidDeaths
where continent is not null
Group By continent
order by TotalDeathCount desc

----Continents with highest death count per population

select continent, Max (cast (total_deaths as int)) as TotalDeathCount from ProjectPortfolio..CovidDeaths
where continent is not null
Group By continent
order by TotalDeathCount desc


-----Retrieving the total new cases , deaths and death percentage globally


set arithabort off
set ansi_warnings off
Select SUM(new_cases) as NewCasesGlobally, SUM(new_deaths) as NewDeathsGlobally, SUM(new_deaths)/SUM(New_Cases)*100 as TotalDeathPercentage
From ProjectPortfolio..CovidDeaths
--Where location like '%states%'
where continent is not null 
----Group By date
order by 1,2


select * from ProjectPortfolio..CovidVaccinations

--Total Population got vaccinated

select D.continent, d.location, D.date,D.population ,V.new_vaccinations 
,sum(cast (V.new_vaccinations as int)) over(partition by D.location order by D.location,D.date) as TotalPeopleVaccinated
from ProjectPortfolio..CovidDeaths D
join ProjectPortfolio..CovidVaccinations V
on D.location = V.location
and D.date = V.date
where D.continent is not null
order by 2,3

---Using CTE
with PopvsVac (continent,location, date,population, new_vaccinations, TotalPeopleVaccinated)
as 
(
select D.continent, d.location, D.date,D.population ,V.new_vaccinations 
,sum(cast (V.new_vaccinations as int)) over(partition by D.location order by D.location,D.date) as TotalPeopleVaccinated
from ProjectPortfolio..CovidDeaths D
join ProjectPortfolio..CovidVaccinations V
on D.location = V.location
and D.date = V.date
where D.continent is not null
---order by 2,3
)
select * , (TotalPeopleVaccinated/population)*100
from PopvsVac

----Temp Table

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
TotalPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select D.continent, d.location, D.date,D.population ,V.new_vaccinations 
,sum(cast (V.new_vaccinations as int)) over(partition by D.location order by D.location,D.date) as TotalPeopleVaccinated
from ProjectPortfolio..CovidDeaths D
join ProjectPortfolio..CovidVaccinations V
on D.location = V.location
and D.date = V.date
where D.continent is not null

select * , (TotalPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


create view #PercentPopulationVaccinated as
select D.continent, d.location, D.date,D.population ,V.new_vaccinations 
,sum(cast (V.new_vaccinations as int)) over(partition by D.location order by D.location,D.date) as TotalPeopleVaccinated
from ProjectPortfolio..CovidDeaths D
join ProjectPortfolio..CovidVaccinations V
on D.location = V.location
and D.date = V.date
where D.continent is not null