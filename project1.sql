show tables ;
select * from hr ;

-- data cleaning and prepocessing --
Delete from hr where birthdate>=curdate();

alter table hr
change column ï»¿id emp_id Varchar (20) NuLL;

describe hr;

select gender, count(*) as count from hr
group by gender;

select department, count(*) from hr
where termdate is null
group by department ;

set sql_safe_updates = 0;

-- change the date format and data type of birthdate --
update hr
set birthdate  = case 
	when birthdate like '%/%' then date_format(str_to_date( birthdate, '%m/%d/%Y'), '%Y-%m-%d')
    when birthdate like '%-%' then date_format(str_to_date( birthdate, '%m-%d-%Y'), '%Y-%m-%d')
    else null
    end;
    
    alter table hr
    modify column birthdate date ;
    
 -- change the date format and data type of hire_date --   
update hr
set hire_date  = case 
	when hire_date like '%/%' then date_format(str_to_date( hire_date, '%m/%d/%Y'), '%Y-%m-%d')
    when hire_date like '%-%' then date_format(str_to_date( hire_date, '%m-%d-%Y'), '%Y-%m-%d')
    else null
    end;
    
alter table hr
modify column hire_date date ;
    
-- change the date format and data type of termdate --
    
    update hr
    set termdate = date(str_to_date( termdate, '%Y-%m-%d %H:%i:%s UTC'))
    where termdate is not null and termdate!='';
    
    update hr
    set termdate = null 
    where termdate='';
    
    -- add column age --
    alter table hr
    add column age int ;
    
    update hr
    set age = timestampdiff(year, birthdate, curdate());
    
    select min(age), max(age) from hr;
    
    -- 1. What is the gender breakdown of the current employees (not terminated) in the company? --
    select gender, count(*) as count from hr
    where termdate is null
    group by gender ;
    
    -- 2. What is the race breakdown of the current employees (not terminated) in the company?
    select race, count(*) as count from hr
    where termdate is null 
    group by race;
    
    -- 3. What is the age distribution of employees in the company?
    select
		case
        when age>=18 and age<=24 then '18-24'
        when age>=25 and age<=34 then '25-34'
        when age>=35 and age<=44 then '35-44'
        when age>=45 and age<=54 then '45-54'
        when age>=55 and age<=64 then '55-64'
        else '65+'
        end as age_group,
        count(*) as count
        from hr
        where termdate is null
        group by age_group
        order by age_group;
    
    -- 4. How many employees work at headquarters and remote?
    select location, count(*) from hr
    where termdate is null
    group by location;
    
    -- 5. What is the average length of employment of employees who have been terminated?
    select round(avg(year(termdate)-year(hire_date)),0) as length_of_emp from hr
    where termdate is not null and termdate<=curdate();
    
    -- 6. How does the gender distribution vary across department and jobtitles? 
    select department, jobtitle, gender, count(*) as count 
    from hr
    where termdate is null
    group by department, jobtitle,gender
    order by department, jobtitle,gender;
    
	select department, gender, count(*) as count 
    from hr
    where termdate is null
    group by department, gender
    order by department, gender;
    
    -- 7. What is the distribution of jobtitles across the comapny?
    select jobtitle, count(*) as count from hr
    where termdate is null
    group by jobtitle;
    
    -- 8. Which department has the higher turnover/termination rate?
    
    select department, count(*) as total,
    count( case 
		when termdate is not null and termdate<= curdate() then 1
        end) as terminated_count,
	round((count( case
		when termdate is not null and termdate<=curdate() then 1
        end)/count(*))*100,2) as termination_rate
        from hr
        group by department 
        order by termination_rate desc ;
        
-- 9. What is the distribution of employees across the location_state?
select location_state, count(*) as count from hr
where termdate is null
group by location_state; 

select location_city, count(*) as count from hr
where termdate is null
group by location_city; 

-- 10. How has the company's employee count changed over time based on the hire and termination rate?
select years, terminations, hires, hires-terminations as net_change, (terminations/hires)*100 as change_rate
from (
		select year(hire_date) as years,
        count(*) as hires,
        count( case 
			when termdate is not null and termdate <= curdate() then 1
            end) as terminations
            from hr
            group by year(hire_date) ) as subquery
	group by years
    order by years;
    
-- 11. What is the tenure distribution for each department?
select department, round(avg(datediff(termdate, hire_date)/365),0)  -- datediff then/365 used gives same result as
as avg_tenure														-- year(hire_date)-year(termdate)
from hr
where termdate is not null and termdate <= curdate()
group by department ;


-- 12.Breakdown of termination and hires
-- Gender wise 
select gender, hires, terminations, round((terminations/hires)*100,2) as termination_rate
from (select gender,
	count(*) as hires,
	count(case
	when termdate is not null and termdate <= curdate() then 1 
    end) as terminations
    from hr
    group by gender) as subquery
group by gender ;

-- Age wise
select age, hires, terminations, round((terminations/hires)*100,2) as termination_rate
from (select age,
	count(*) as hires,
	count(case
	when termdate is not null and termdate <= curdate() then 1 
    end) as terminations
    from hr
    group by age) as subquery
group by age ;

-- Dept wise
select department, hires, terminations, round((terminations/hires)*100,2) as termination_rate
from (select department,
	count(*) as hires,
	count(case
	when termdate is not null and termdate <= curdate() then 1 
    end) as terminations
    from hr
    group by department) as subquery
group by department ;

-- Year wise
select years, hires, terminations, round((terminations/hires)*100,2) as termination_rate
from (select year(hire_date) as years,
	count(*) as hires,
	count(case
	when termdate is not null and termdate <= curdate() then 1 
    end) as terminations
    from hr
    group by years) as subquery
group by years
order by years ;

-- race wise
select race, hires, terminations, round((terminations/hires)*100,2) as termination_rate
from (select race,
	count(*) as hires,
	count(case
	when termdate is not null and termdate <= curdate() then 1 
    end) as terminations
    from hr
    group by race) as subquery
group by race ;