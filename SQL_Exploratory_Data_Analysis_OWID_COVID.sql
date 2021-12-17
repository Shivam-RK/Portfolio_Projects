--Downloaded .csv data for Covid Deaths and Vaccinations (Dataset: https://ourworldindata.org/covid-deaths); 
--Beginning MySQL Process;
--Creating TABLE on COVID DEATHS;
create table Data_Covid_Deaths0(
iso_code	text,
continent	text,
location	text,
date	varchar(50),
population	bigint,
total_cases	bigint,
new_cases	bigint,
total_deaths	bigint,
new_deaths	bigint);
--Creating TABLE on COVID VACCINATIONS;
create table Data_Covid_Vaccinations1(
iso_code  text,
continent text,
location text,
date datetime,
new_tests bigint,
total_tests bigint,
positive_rate double,
total_vaccinations bigint,
people_fully_vaccinated bigint,
new_vaccinations bigint,
stringency_index double,
aged_70_older double,
gdp_per_capita double,
hospital_beds_per_thousand double,
life_expectancy double,
excess_mortality_cumulative double);
----------------------------------------------------------------------------------------------------------------------------
--LOADING DATA INTO TABLE FOR COVID DEATHS;
load data local infile "C:\\Users\\91999\\Desktop\\SQL\\CovidProject\\2_12_21_OWID_COVIDDEATHS.csv"
into table Data_Covid_Deaths0
fields terminated by ","
ignore 1 rows;
--We are ignoring 1 row because it contains column headers;
--Viewing Data on Covid Deaths;
select * from Data_Covid_Deaths0;
--LOADING DATA INTO TABLE FOR COVID VACCINATIONS;
load data local infile "C:\\Users\\91999\\Desktop\\SQL\\CovidProject\\01_12_2021_CovidVaccinations_limitedcols2.csv"
into table Data_Covid_Vaccinations1
fields terminated by ","
ignore 1 rows;
--Viewing Data and row counts for Covid Deaths;
SELECT * FROM Data_Covid_Deaths0;
Select count(*) FROM Data_Covid_Deaths0;
--Count of Records is '136931';
--Due to difficulties with importing datetime columns, the Date column was imported as string and is now being transformed into original date based type;
--Changing Date Column from varchar(50) to Date type;
UPDATE Data_Covid_Deaths0 SET date= STR_TO_DATE(REPLACE(date,'-','.'),GET_FORMAT(DATE,'EUR'));
ALTER TABLE Data_Covid_Deaths0 CHANGE date date DATETIME;
--Viewing Data and row counts for Covid Vaccinations;
SELECT * FROM Data_Covid_Vaccinations1;
SELECT count(*) FROM Data_Covid_Vaccinations1;
--Count of Records is '136931';
----------------------------------------------------------------------------------------------------------------------------
--Total Cases vs Total Deaths by Date and Location;
Select Date, location, total_cases,total_deaths, TRUNCATE((total_deaths/total_cases),4) *100 as 'Covid_Case_Fatality_Rate(%)' from Data_Covid_Deaths0 order by 2,1;
--Total Cases vs Population;
Select Date, location, total_cases,Population, Truncate((total_cases/population),10) *100 as 'Covid_Cases_per_capita_percentage(%)' from Data_Covid_Deaths0 order by 2,1;
--Total Deaths vs Population;
Select Date, location, total_deaths,Population, (total_deaths/population) *100 as 'Covid_Deaths_per_capita_percentage(%)' from Data_Covid_Deaths0 order by 2,1;
--Date of Maximum Covid Case Rate Recorded by Country;
Select date,continent,location, max(total_cases/population) *100 as 'Highest Infection Rate by Country(%)' from Data_Covid_Deaths0 where continent IS NOT NULL AND continent != '' group by location order by 4 desc;
--Highest Infection Rate By Location;
Select date, location,max(total_cases/population) *100 as 'highest infection rate by country (%)' from Data_Covid_Deaths0  group by location order by 2 desc;
--Average Covid Cases to Population by Location;
Select location, truncate(avg(total_cases/population),4) *100 as 'Average_Covid_Case_Rate vs Population(%)' from Data_Covid_Deaths0 where continent IS NOT NULL AND continent != '' group by location order by 2 desc;
--Maximum Mortality of Population per Location;
Select date,continent,location, max(total_deaths/population) *100 as 'Maximum_Covid_Mortality_Rate_in_Population(%)' from Data_Covid_Deaths0 where continent IS NOT NULL AND continent != '' group by location order by 4 desc;
--Maximum Recorded Cases by Country;
select date, location, max(total_cases) as 'Total Recorded Cases' from Data_Covid_Deaths0 where continent IS NOT NULL AND continent != '' group by location order by 3 desc;
--Maximum Absolute Mortality by Country;
select date, location, max(total_deaths) as 'Current Absolute Recorded Covid Mortality' from Data_Covid_Deaths0 where continent IS NOT NULL AND continent != '' group by location order by 3 desc;
----------------------------------------------------------------------------------------------------------------------------
--Grouping Data by Continent;
select continent, sum(total_deaths) as 'Continent-wide deaths' from Data_Covid_Deaths0 where continent IS NOT NULL AND continent != '' group by continent order by 2 desc; 
select continent, sum(total_cases) as 'Continent-wide cases' from Data_Covid_Deaths0 where continent IS NOT NULL AND continent != '' group by continent order by 2 desc; 
select continent, sum(total_deaths)/sum(population)*100 as 'Continent-wide mortality rate(%)' from Data_Covid_Deaths0 where continent IS NOT NULL AND continent != '' group by continent order by 2 desc; 
select continent, sum(total_cases)/sum(population)*100  as 'Continent-wide case rate(%)' from Data_Covid_Deaths0 where continent IS NOT NULL AND continent != '' group by continent order by 2 desc;
select continent, truncate(sum(total_deaths/population)*1000000,2) as 'Deaths per million population' from Data_Covid_Deaths0 where continent IS NOT NULL AND continent != '' group by continent order by 2 desc;
----------------------------------------------------------------------------------------------------------------------------
--Global Data;
--Total New Cases and Total New Deaths Recorded Globally on a Daily Basis; 
Select date, sum(new_cases) as new_cases_identified_global_in_last_24_hours, sum(new_deaths) as new_deaths_global_in_last_24_hours from Data_Covid_Deaths0 where continent IS NOT NULL AND continent != '' group by date order by 1;
--Global Case Fatality Rate on a Daily Basis;
Select date, truncate(((total_deaths)/(total_cases))*100,2) as 'Global Case Fatality Rate(%)'  from Data_Covid_Deaths0 where continent IS NOT NULL AND continent != '' group by date order by 1;
--Global Cases Recorded by Global Population on a Daily Basis;
Select date, truncate((total_cases/population)*100,2) as 'Global Case Rate(%)'  from Data_Covid_Deaths0 where continent IS NOT NULL AND continent != '' group by date order by 1;
--Global Cases by Global Population;
Select date, truncate((sum(total_cases)/sum(population))*100,2) as 'Global Cases by Global Population(%)'  from Data_Covid_Deaths0 where continent IS NOT NULL AND continent != '' group by date order by 1;
--New Deaths and Cases added on each day Globally;
Select date, SUM(new_cases) as New_Global_Cases, sum(new_deaths) as New_Global_Deaths from Data_Covid_Deaths0 where continent IS NOT NULL AND continent != '' group by date order by 1;
--select date, truncate((sum(new_cases)/population/1000),8) as new_cases_per_thousand_population,truncate((sum(new_deaths)/population/1000),2) as new_deaths_per_thousand_population from Data_Covid_Deaths0 where continent IS NOT NULL AND continent != '' group by date order by 1;
--Daily Global Death per Case Data;
--Global Death per Case Data in Total using sum of new cases and new deaths;
Select date,sum(new_cases) as Cases_Since_Start, sum(new_deaths) as Deaths_Since_Start, truncate((sum(new_deaths) /sum(new_cases))*100,2) as Death_per_Case_Percentage_Across_World from Data_Covid_Deaths0 where continent IS NOT NULL AND continent != '' group by date order by 1;
--Using Vaccination Data;
SELECT * FROM Data_Covid_Vaccinations1;
select count(*) from data_covid_vaccinations1 where continent IS NOT NULL AND continent != '';
select count(*) from Data_Covid_Deaths0 where continent IS NOT NULL AND continent != '';
--8721=136931-128210 records excluded;
----------------------------------------------------------------------------------------------------------------------------
--Joining tables with a temp table;
Create Temporary Table djv_table_1
(iso_code	text,
continent	text,
location	text,
date	varchar(50),
population	bigint,
total_cases	bigint,
new_cases	bigint,
total_deaths bigint,
new_deaths	bigint,
iso_code1	text,
continent1	text,
location1	text,
date1	varchar(50),
new_tests bigint,
total_tests bigint,	
positive_rate double,	
total_vaccinations bigint,	
people_fully_vaccinated bigint,	
new_vaccinations bigint,	
stringency_index double,	
aged_70_older double,	
gdp_per_capita double,	
hospital_beds_per_thousand double,	
life_expectancy double,	
excess_mortality_cumulative double);

Insert into djv_table_1
(
Select * from Data_Covid_Deaths0 d
join data_covid_vaccinations1 v on d.location = v.location and d.date = v.date 
where d.continent IS NOT NULL AND d.continent != '');
SHOW fields from djv_table_1;
----------------------------------------------------------------------------------------------------------------------------
--Viewing New Temp Table Data;
select * from djv_table_1;
select distinct location from djv_table_1 order by population desc;
--djv_table does not include empty continent cells nor aggregated regions;
Select count(*) from djv_table_1; 
--128210 records
----------------------------------------------------------------------------------------------------------------------------
--Global Population vs Full Vaccinations;
Select truncate(max(people_fully_vaccinated)/sum(distinct population),4)*100 as populationvaccinated_percentage from djv_table_1;
---Daily new vaccinations by country by day;
Select date, continent, location, new_vaccinations as daily_vaccinations from djv_table_1;
--Count of days where people have been vaccinated by location and with total sum of vaccinated:
Select location, count(new_vaccinations) as Number_of_Vaccination_Days, sum(new_vaccinations) as Total_Vaccinations, sum(new_deaths) as Total_Deaths, population from djv_table_1  where new_vaccinations>0 group by location order by 2;
---Daily new vaccinations globally by date;
Select date, sum(new_vaccinations) as global_daily_vaccinations from djv_table_1 group by date;
----------------------------------------------------------------------------------------------------------------------------
--Rolling Count of Cases are first recorded in a location;
select date, continent, location,  population, new_cases, SUM(new_cases) OVER (partition by location Order by location, date) as Rolling_Count_Of_Cases from djv_table_1 where new_cases>0; 

--Rolling Count of Vaccinations starting after vaccinations begin in a location;
select date, continent, location,  population, new_vaccinations, SUM(new_vaccinations) OVER (partition by location Order by location, date) as Rolling_Count_Of_Vaccinations from djv_table_1 where new_vaccinations>0; 

--Rolling Count of Deaths  after first recorded deaths in a location;
select date, continent, location,  population, new_deaths, SUM(new_deaths) OVER (partition by location Order by location, date) as Rolling_Count_Of_Deaths from djv_table_1 where new_deaths>0; 

--Rolling Count of Cases, Deaths and Vaccinations since first records of each per location;
select date, continent, location, population, new_cases, SUM(new_cases) OVER (partition by location Order by location,date) as Rolling_Count_Of_Cases, new_vaccinations, SUM(new_vaccinations) OVER (partition by location Order by location,date) as Rolling_Count_Of_Vaccinations, new_deaths, SUM(new_deaths) OVER (partition by location Order by location,date) as Rolling_Count_Of_Deaths from djv_table_1 where (new_cases>0 or new_vaccinations>0 or new_deaths>0); 

--Rolling Count of Cases, Deaths and Vaccinations since first records of each per locaiton without daily additions;
select date, continent, location, population, SUM(new_cases) OVER (partition by location Order by location,date) as Rolling_Count_Of_Cases, SUM(new_vaccinations) OVER (partition by location Order by location,date) as Rolling_Count_Of_Vaccinations, SUM(new_deaths) OVER (partition by location Order by location,date) as Rolling_Count_Of_Deaths from djv_table_1 where (new_cases>0 or new_vaccinations>0 or new_deaths>0); 
----------------------------------------------------------------------------------------------------------------------------
--Correlation of Stringency Index of Locations and Covid Deaths;
select @ax := avg(stringency_index), 
       @ay := avg(total_deaths), 
       @div := (stddev_samp(stringency_index) * stddev_samp(total_deaths))
from djv_table_1;
select truncate(sum(( stringency_index - @ax ) * (total_deaths - @ay) ) / ((count(stringency_index) -1) * @div),4) as Correlaiton_of_Covid_Deaths_and_Stringency from djv_table_1;

--Correlation of GDP_Capita Locations and Covid Deaths;
select @bx := avg(gdp_per_capita), 
       @ay := avg(total_deaths), 
       @div := (stddev_samp(gdp_per_capita) * stddev_samp(total_deaths))
from djv_table_1;
select truncate(sum((gdp_per_capita - @bx ) * (total_deaths - @ay) ) / ((count(gdp_per_capita) -1) * @div),4) as Correlaiton_of_Covid_Deaths_and_GDP_per_Capita from djv_table_1;

--Correlation of Population aged over 70 of Locations and Covid Deaths;
select @cx := avg(aged_70_older), 
       @ay := avg(total_deaths), 
       @div := (stddev_samp(aged_70_older) * stddev_samp(total_deaths))
from djv_table_1;
select truncate(sum((aged_70_older - @cx ) * (total_deaths - @ay) ) / ((count(aged_70_older) -1) * @div),4) as Correlaiton_of_Covid_Deaths_and_Population_Aged_Over_70 from djv_table_1;

--Correlation of Hospital Beds (000s) and Covid Deaths;
select @dx := avg(hospital_beds_per_thousand), 
       @ay := avg(total_deaths), 
       @div := (stddev_samp(hospital_beds_per_thousand) * stddev_samp(total_deaths))
from djv_table_1;
select truncate(sum((hospital_beds_per_thousand - @dx ) * (total_deaths - @ay) ) / ((count(hospital_beds_per_thousand) -1) * @div),4) as Correlaiton_of_Covid_Deaths_and_Hospital_Beds_in_Thousands from djv_table_1;

--Viewing above Correlations Simultaneously;
select truncate(sum(( stringency_index - @ax ) * (total_deaths - @ay) ) / ((count(stringency_index) -1) * @div),6) as Correlaiton_of_Covid_Deaths_and_Stringency, 
truncate(sum((gdp_per_capita - @bx ) * (total_deaths - @ay) ) / ((count(gdp_per_capita) -1) * @div),6) as Correlaiton_of_Covid_Deaths_and_GDP_per_Capita,
truncate(sum((aged_70_older - @cx ) * (total_deaths - @ay) ) / ((count(aged_70_older) -1) * @div),6) as Correlaiton_of_Covid_Deaths_and_Population_Aged_Over_70,
truncate(sum((hospital_beds_per_thousand - @dx ) * (total_deaths - @ay) ) / ((count(hospital_beds_per_thousand) -1) * @div),6) as Correlaiton_of_Covid_Deaths_and_Hospital_Beds_in_Thousands from djv_table_1;
----------------------------------------------------------------------------------------------------------------------------
--Using Common Table Expression (CTE) to find Rolling Count of Vaccinations and Rolling Percentage of Population Vaccinated by Location--;
With PopVsVac (Continent, Location, Date, Population,new_vaccinations, RollingCountOfVaccinations)
as
(select continent , location, date, population, new_vaccinations, SUM(new_vaccinations) OVER (partition by Location Order by location,date) as 'Rolling_Count_Of_Vaccinations' from djv_table_1)
select *,(RollingCountOfVaccinations/Population)*100 as Rolling_Percentage_Of_Vaccinated_Population from PopVsVac;
----------------------------------------------------------------------------------------------------------------------------
--Using Common Table Expression (CTE) to find Global Rolling Count of Vaccinations and Rolling Percentage of Population Vaccinated-;
SELECT @GlobalPop := sum(distinct Population) from djv_table_1;
With GlobalPopVsVac (Date, Population, Rolling_Count_Of_Global_Vaccinations)
as
(select date, round(@GlobalPop), SUM(new_vaccinations) OVER (partition by Date Order by date) as Rolling_Count_Of_Global_Vaccinations from djv_table_1)
select *,(Rolling_Count_Of_Global_Vaccinations/@GlobalPop)*100 as Rolling_Percentage_Of_Globally_Vaccinated_Population from GlobalPopVsVac;
----------------------------------------------------------------------------------------------------------------------------
--Creating Views To Store Data for Later Visualization--;
Create View PPVViz1 as
(select d.continent , d.location, d.date, d.population, v.new_vaccinations, SUM(v.new_vaccinations) OVER (partition by d.Location Order by d.location,d.date) as 'RollingCountOfVaccinations' from Data_Covid_Deaths0 d
join data_covid_vaccinations1 v on d.location = v.location and d.date = v.date);

--Creating View to keep rolling statistics per location;
Create View PPVViz2 as
(select d.date, d.continent, d.location, d.population, SUM(d.new_cases) OVER (partition by d.location Order by d.location,d.date) as Rolling_Count_Of_Cases, 
SUM(v.new_vaccinations) OVER (partition by v.location Order by v.location,v.date) as Rolling_Count_Of_Vaccinations, 
SUM(d.new_deaths) OVER (partition by d.location Order by d.location,d.date) as Rolling_Count_Of_Deaths from Data_Covid_Deaths0 d 
join data_covid_vaccinations1 v on d.location = v.location and d.date = v.date
where ((d.new_cases>0 or v.new_vaccinations>0 or d.new_deaths>0) and d.continent IS NOT NULL AND d.continent != ''));

--Creating View to keep rolling statistics per continent;
Create View PPVViz3 as
(select d.date, d.continent, d.population = (select sum(population) from Data_Covid_Deaths0 e where e.continent=d.continent), sum(d.new_cases) OVER (partition by d.continent Order by d.continent,d.date) as Rolling_Count_Of_Cases, 
sum(v.new_vaccinations) OVER (partition by v.continent Order by v.continent,v.date) as Rolling_Count_Of_Vaccinations, 
sum(d.new_deaths) OVER (partition by d.continent Order by d.continent,d.date) as Rolling_Count_Of_Deaths from Data_Covid_Deaths0 d 
join data_covid_vaccinations1 v on d.location = v.location and d.date = v.date
where ((d.new_cases>0 or v.new_vaccinations>0 or d.new_deaths>0) and d.continent IS NOT NULL AND d.continent != ''));
----------------------------------------------------------------------------------------------------------------------------
