
--The dataset used is the South African national income dynamic study (NIDS). 
--The study follows individuals and households over time and records their income,
--health, and other measure of standard of living . 
--The study follows a sample of 28 000 individuals in 7 300 households across South Africa 
--and is repeated every two years. 
--The currently available dataset includes 5 waves with the most recent conducted in 2017. 
--The focus of my queries will be on several determinants of income.

--See "https://public.tableau.com/app/profile/lyle.begbie" where some of these queries have been visualised in Tableau
--Data obtained from https://www.datafirst.uct.ac.za/
--The uploaded tables are extracts from the wave 5 file of NIDS.


select *
from NIDSProject..adult
--This table shows questions directed to adults


select *
from NIDSProject..household
--This table shows questions directed to households


select *
from NIDSProject..individ
--This table shows questions directed to individudals
--Wages column constructed by adding in wages from casual work,self-employed and salaries

--Determinants of income in South Africa

--Aggregate function to look at income
select max(wage) as Max_wage
from NIDSProject..Individ
-- The highest montly wage in the sample is 189 000 per month

--Education
--Different type of education
select distinct w5_best_edu
from NIDSProject..individ


select w5_best_edu,avg(wage) as Monthly_wages
from NIDSProject..individ
group by w5_best_edu
order by Monthly_wages DESC
--This shows that invidiuals with N1 education have the highest wages.
--This value looks suspicious and might be driven by low sample size.


select w5_best_edu,avg(wage) as Monthly_wages,count(Wage) as Number
from NIDSProject..individ
group by w5_best_edu
order by Monthly_wages DESC
--Including a count shows that results from the previous query were driven by small sample sizes



select w5_best_edu,avg(wage) as Monthly_wages,count(Wage) as Number
from NIDSProject..individ
group by w5_best_edu
Having count(wage)>5
order by Monthly_wages DESC
--Only including educations groups with sample wages more than 5 values provides a clearer picture
--As expected,those with higher level of education have higher wages. This includes those without income.


select w5_best_edu,avg(wage) as Monthly_wages,count(Wage) as Number
from NIDSProject..individ
where wage>0
group by w5_best_edu
Having count(wage)>5
order by Monthly_wages DESC
--Including wages above zero provides a clearer picture of actual wages based on education level



--Finding wages by age
select w5_best_age_yrs,avg(wage) as Monthly_wages,count(Wage) as Number
from NIDSProject..individ
where wage>0
group by w5_best_age_yrs
Having count(wage)>5
order by w5_best_age_yrs DESC;
--The clear trend is that higher ages have higher average wages, peaking in the 60s age

--Wage and race
select w5_best_race,avg(wage) as Monthly_wages,count(Wage) as Number
from NIDSProject..individ
where wage>0
group by w5_best_race
Having count(wage)>5


--Wage and gender
select w5_best_gen,avg(wage) as Monthly_wages,count(Wage) as Number
from NIDSProject..individ
where wage>0
group by w5_best_gen
Having count(wage)>10


--Wage and Marriage Status
select w5_best_marstt,avg(wage) as Monthly_wages,count(Wage) as Number
from NIDSProject..individ
where wage>0
group by w5_best_marstt
Having count(wage)>6
order by  Monthly_wages DESC
--Interesting is that the divorced/seperated category has the highest monthly wages


--Next is to create a join
--This query compares the constructed wage to that in the survey
select ind.w5_hhid, ind.pid, adu.w5_a_em1pay, ind.Wage
from NIDSProject..Adult adu
join NIDSProject..Individ ind
on ind.w5_hhid= adu.w5_hhid
and ind.pid=adu.pid
where ind.Wage>0
--where w5_a_em1pay is not null
order by 3,4
--The constructed wage is more extensive and has more data

--Next is to obtain geography/location from the household table

select *
from NIDSProject..household


--Making use of view to save the query as a table
--This will create a table that combines the geography data from the household table and
--the income data from the individ table
--This will make it possible to analyse the role of income and geography
drop view if exists WageByGeography
create view WageByGeography as
select ind.w5_hhid, ind.pid, ind.Wage, hou.w5_prov2011,hou.w5_geo2011,hou.w5_dc2011,hou.w5_hhsizer,ind.w5_best_race,ind.w5_best_age_yrs
from NIDSProject.. Individ ind
join NIDSProject..Household hou
on ind.w5_hhid= hou.w5_hhid
--where ind.Wage>0

--A query is from the created geography view
-- Wage by urban/rural
select w5_geo2011,avg(wage) as Monthly_wages,count(Wage) as Number
from WageByGeography
group by w5_geo2011
Having count(wage)>1
order by Monthly_wages DESC
--It is clear that urban areas have the highest wages



-- Comparing provinces and thier wages
select w5_prov2011,avg(wage) as Monthly_wages,count(Wage) as Number
from WageByGeography
group by w5_prov2011
Having count(wage)>1
order by Monthly_wages DESC
--Gauteng has the highest wages and KZN the lowest


--Wage and race and province
select w5_best_race,avg(wage) as Monthly_wages,count(Wage) as Number
from WageByGeography
where wage>0 and w5_prov2011='Gauteng'
group by w5_best_race
Having count(wage)>0


-- Comparing local municipalities and their average wages
select w5_dc2011,avg(wage) as Monthly_wages,count(Wage) as Number
from WageByGeography
where wage>0 and w5_best_race='Coloured'
group by w5_dc2011
Having count(wage)>1 
order by Monthly_wages DESC
--City of Tshwane and City of Johannesburg have the highest wages and most number of people employed in the sample.


--Wages by household size
select w5_hhsizer,avg(wage) as Monthly_wages,count(Wage) as Number
from WageByGeography
group by w5_hhsizer
Having count(wage)>20
order by w5_hhsizer
--The trend is that the larger the household, the smaller the individual monthly wage

--
--Finding the percantage employed per province
-- This is done using the "case when ... then" statement
--Sets a value of 100 for when employed and zero otherwise.
--Thus the average of this value conditional on province/district should provide the employment rate.
--Contitional on those above the age of 21 to represent only adults
select w5_prov2011,
AVG(CASE WHEN wage>0 THEN 100
ELSE 0
END) as employment_rate,
count(Wage) as Number
from WageByGeography
where w5_best_age_yrs>21
group by w5_prov2011
order by employment_rate DESC
-- This provides some context to the wage numbers


--Now compare the employment rate in district municipalities
select w5_dc2011,
AVG(CASE WHEN wage>0 THEN 100
ELSE 0
END) as employment_rate,
count(Wage) as Number
from WageByGeography
where w5_best_age_yrs>21
group by w5_dc2011
order by employment_rate DESC
-- In terms of employment rate, the west rand seems to have the highest.




--The next step is to split each province by individuals living in a farming,urban or traditional household
--Not able to use the where function for multiple conditions.

select *
from WageByGeography

select distinct w5_geo2011
from WageByGeography
--Instead will attempt to use  common table expressions (CTEs)
--find out how urban each province is using CTEs
WITH CTE_urban as 
(select w5_prov2011,count(w5_geo2011) as Urban
from WageByGeography
where w5_geo2011='Urban'
group by w5_prov2011)
select *
from CTE_urban

--Focusing on CTE_urban was used as a test
--Multiple CTEs and using case and count and group

WITH CTE_farms as 
(select pid,w5_prov2011,
(CASE WHEN w5_geo2011='Farms'THEN 1
ELSE 0
END) as Farms
from WageByGeography),
CTE_Urban as 
(select pid,w5_prov2011,
(CASE WHEN w5_geo2011='Urban'THEN 1
ELSE 0
END) as Urban
from WageByGeography),
 CTE_Trad as 
 (select pid,w5_prov2011,
(CASE WHEN w5_geo2011='Traditional'THEN 1
ELSE 0
END) as Traditional
from WageByGeography)
select sum(Farms),sum(Urban),sum(Traditional)
from CTE_farms,CTE_Urban,CTE_Trad
group by w5_prov2011..CTE_farms
--Using multiple CTE tables took too long, will make use of temp tables instead.

--Try using a temp table.
--This will require the creation of multiple temp tables each with a different where condition
.
drop table if exists #temp_urban
create table #temp_urban(
Province varchar(50),
Urban int)

insert into #temp_urban
select w5_prov2011, count(w5_geo2011)
from WageByGeography
where w5_geo2011='Urban'
group by w5_prov2011

select *
from #temp_urban

drop table if exists #temp_farm
create table #temp_farm(
Province varchar(50),
Farm int)

insert into #temp_farm
select w5_prov2011, count(w5_geo2011)
from WageByGeography
where w5_geo2011='farms'
group by w5_prov2011

drop table if exists #temp_trad
create table #temp_trad(
Province varchar(50),
Traditional int)

insert into #temp_trad
select w5_prov2011, count(w5_geo2011)
from WageByGeography
where w5_geo2011='Traditional'
group by w5_prov2011


drop table if exists #temp_total
create table #temp_total(
Province varchar(50),
Urban int,
Farm int,
Traditional int)

insert into #temp_total
select ur.Province, ur.Urban, fa.Farm, tr.Traditional
from #temp_urban ur
Full outer join #temp_farm fa
on ur.Province= fa.Province
full outer join #temp_trad tr
on fa.Province=tr.Province


select *
from #temp_total
--Table listing multiple provinces by the count of households that are urban,farm or traditional
--Gauteng has the most urban households and KZN has the most traditional households.


--Next step is to extract data for district municipalities and visualize it in Tableau

drop table if exists #temp_urban
create table #temp_urban(
District varchar(50),
Urban int)

insert into #temp_urban
select w5_dc2011, count(w5_geo2011)
from WageByGeography
where w5_geo2011='Urban'
group by w5_dc2011


select *
from #temp_urban
order by District

drop table if exists #temp_farm
create table #temp_farm(
District varchar(50),
Farm int)

insert into #temp_farm
select w5_dc2011, count(w5_geo2011)
from WageByGeography
where w5_geo2011='farms'
group by w5_dc2011


drop table if exists #temp_trad
create table #temp_trad(
District varchar(50),
Traditional int)

insert into #temp_trad
select w5_dc2011, count(w5_geo2011)
from WageByGeography
where w5_geo2011='Traditional'
group by w5_dc2011



drop table if exists #temp_total
create table #temp_total(
District varchar(50),
Urban int,
Farm int,
Traditional int)

insert into #temp_total
select ur.District, ur.Urban, fa.Farm, tr.Traditional
from #temp_urban ur
full outer join #temp_farm fa
on ur.District= fa.District
full outer join #temp_trad tr
on fa.District=tr.District
or ur.District=tr.District

select *
from #temp_total
order by District



















