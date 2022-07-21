-- percent of total deaths to tot cases
select location,max(population)as pop,
max(total_cases) as tot_c,
max(total_deaths) as tot_d,
((max(total_deaths)/max(total_cases)::float)*100) as percent
from coviddeath
WHERE continent IS NOT NULL
GROUP BY location
HAVING max(total_cases) is not null and max(total_deaths) IS NOT NULL
ORDER BY percent desc
------------------------------------------
-- percent of total casess to  population
SELECT location,
max(population) as pop ,
max(total_cases) as tot_c,
((max(total_cases)/max(population)::float)*100) as percent
from coviddeath
WHERE continent IS NOT NULL
GROUP BY location
HAVING max(population) IS NOT NULL AND max(total_cases) IS NOT NULL
ORDER BY percent DESC
------------------------------------------
-- percent of total deaths to population
SELECT location,
max(population) as pop ,
max(total_deaths) as tot_d ,
((max(total_deaths)/max(population)::float)*100) as percent
from coviddeath
WHERE continent IS NOT NULL
GROUP BY location
HAVING max(population) IS NOT NULL AND max(total_deaths) IS NOT NULL
ORDER BY percent DESC


select*
from coviddeath as cd
join covidvac as cv
on cd.location = cv.location and cd.date = cv.date
order by cd.location

-- Global cases, deaths and, its ratio
select sum(new_cases) as global_cases , sum(new_deaths) as global_deaths,
((sum(new_deaths)/sum(new_cases)::float)*100) as Rate
from coviddeath


-- Handwashing facilities, cases and deaths for each countrey
select cd.location ,max(cd.total_cases) as tot_cases, max(cd.total_deaths) as tot_deaths, max(cv.handwashing_facilities) as handwashing_facilities
from coviddeath as cd
join covidvac as cv
on cd.location = cv.location and cd.date = cv.date
where handwashing_facilities is not null
group by cd.location
order by cd.location
----------------------------------------------------
-- hospital beds, cases and deaths for each countrey
select cd.location ,max(cd.total_cases) as tot_cases, max(cd.total_deaths) as tot_deaths, max(cv.hospital_beds_per_thousand) as hospital_beds_per_thousand
from coviddeath as cd
join covidvac as cv
on cd.location = cv.location and cd.date = cv.date
where hospital_beds_per_thousand is not null
group by cd.location
order by cd.location
----------------------------------------------------
-- median age, cases and deaths for each countrey
select cd.location ,max(cd.total_cases) as tot_cases, max(cd.total_deaths) as tot_deaths, max(cv.median_age) as median_age
from coviddeath as cd
join covidvac as cv
on cd.location = cv.location and cd.date = cv.date
where median_age is not null
group by cd.location
order by cd.location
----------------------------------------------------
-- population density, cases and deaths for each countrey
select cd.location ,max(cd.total_cases) as tot_cases, max(cd.total_deaths) as tot_deaths, max(cv.population_density) as population_density
from coviddeath as cd
join covidvac as cv
on cd.location = cv.location and cd.date = cv.date
where population_density is not null
group by cd.location
order by cd.location
----------------------------------------------------
-- vaccination accomulated
select cd.location, cd.date, cd.population , cv.new_vaccinations,
sum(new_vaccinations) over(partition by(cd.location) order by(cd.date)) as vaccination_accomulated
from coviddeath as cd
join covidvac as cv
on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null
----------------------------------------------------
-- Showing percent of fully vaccinated people in each country
select cd.location, max(cd.population) as pop , max(cv.people_fully_vaccinated) as vacc, ((max(cv.people_fully_vaccinated)/ max(cd.population)::float)*100) as percent
from coviddeath as cd
join covidvac as cv
on cd.location = cv.location and cd.date = cv.date
group by cd.location
having ((max(cv.people_fully_vaccinated)/ max(cd.population)::float)*100) is not null
order by percent desc
----------------------------------------------------
-- new cases respnsed to the change of stringency index
with t1 as (select location, date, population, new_cases
		    		from coviddeath),
		   t2 as(select location, date,stringency_index
		   			from covidvac)
select t1.location , t1.date,t1.population,t1.new_cases, t2.stringency_index
from t1
join t2 
on t1.location = t2.location and t1.date = t2.date
order by t1.location
-----------------------------------------------------
-- avg_percent_of_total_cases
select avg(percent) avg_percent_of_total_cases
from(select location,max(population) pop ,max(total_cases) as tot_cas ,((max(total_cases)/max(population)::float)*100) as percent
from coviddeath
	 where total_cases is not null and population is not null
group by location
	order by percent) as t1
-----------------------------------------------------
-- avg_percent_of_total_deaths
select avg(percent) avg_percent_of_total_deaths
from(select location,max(total_cases) tot_cas ,max(total_deaths) as tot_deaths ,((max(total_deaths)/max(total_cases)::float)*100) as percent
from coviddeath
	 where total_cases is not null and total_deaths is not null
	 and location not like 'Yemen' and location not like 'Vanuatu'
group by location
	order by percent) as t1