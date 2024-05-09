create database hr_analytics_project;

use hr_analytics_project;

select count(*) from hr_1; 
select count(*) from hr_2;

select * from hr_1;
select * from hr_2;

#----Total Employees----
select count(distinct(Employee_ID)) as Total_Employees
from hr_2;

#---Employees by gender---
select Gender,count(distinct(EmployeeNumber))
from hr_1
group by gender;

#--Attrition count--
select count(Attrition) as Attrition_count
from hr_1
where Attrition = "yes";

#-- Attrition Rate----
select format(avg(a.Attrition_yes)*100,2) as Attrition_rate
from
(select attrition,
       case
       when attrition='yes' 
       then 1 
       else 0
       end as attrition_yes
from hr_1) as a;

#--- Gender wise attrition rate
select a.gender,format(avg(a.attrition_yes)*100,2) as Attrition_rate
 from 
(select gender,attrition,
case 
when Attrition='yes' 
then 1 
else 0 
end as attrition_yes from hr_1) as a
group by gender;

#**********************   KPI   ***************************

#-KPI 1: Average Attrition rate for all Departments----

select a.Department,format(avg(a.attrition_yes)*100,2) as Attrition_Rate
from  
( select department,attrition,
case when attrition='Yes'
then 1
else 0
end as attrition_yes from hr_1 ) as a
group by a.department;

#--KPI 2: Average Hourly rate of Male Research Scientist----

select jobrole,format(avg(hourlyrate),2) as Hourly_Rate,gender
from hr_1 
where jobrole='research scientist' and gender='male';

#--KPI 3: Attrition rate Vs Monthly income stats----

select a.department,
 format(avg(attrition_yes)*100,2) as attrition_rate,
 format(avg(monthlyincome),2) as AVG_monthlyincome 
 from
 (select department,attrition,employeenumber,
 case 
 when attrition='yes'
 then 1
 else 0 
 end as attrition_yes from hr_1)as a
 join
 hr_2 as b on a.employeenumber=b.Employee_ID
 group by a.department; ###
    
#--KPI 4: Average working years for each Department----

select department,format(avg(totalworkingyears),0) as Avg_workingyears
 from 
 hr_1 join hr_2  on hr_1.employeenumber=hr_2.Employee_ID 
 group by department;
 
 #--KPI 5: Job Role Vs Work life balance----
 
  SELECT
    JobRole,
    SUM(CASE WHEN WorkLifeBalanceCategory = 'Poor' THEN 1 ELSE 0 END) AS Poor,
    SUM(CASE WHEN WorkLifeBalanceCategory = 'Average' THEN 1 ELSE 0 END) AS Average,
    SUM(CASE WHEN WorkLifeBalanceCategory = 'Good' THEN 1 ELSE 0 END) AS Good,
    SUM(CASE WHEN WorkLifeBalanceCategory = 'Excellent' THEN 1 ELSE 0 END) AS Excellent
FROM (
    SELECT
        hr_1.JobRole,
        CASE
            WHEN hr_2.WorkLifeBalance >= 1 AND hr_2.WorkLifeBalance < 2 THEN 'Poor'
            WHEN hr_2.WorkLifeBalance >= 2 AND hr_2.WorkLifeBalance < 3 THEN 'Average'
            WHEN hr_2.WorkLifeBalance >= 3 AND hr_2.WorkLifeBalance < 4 THEN 'Good'
            WHEN hr_2.WorkLifeBalance >= 4 THEN 'Excellent'
            ELSE 'Unknown'
        END AS WorkLifeBalanceCategory
    FROM
        hr_1
    INNER JOIN
        hr_2 ON hr_1.EmployeeNumber = hr_2.Employee_ID
) AS subquery
GROUP BY
    JobRole;
 

 #---- KPI 6: Attrition rate Vs Year since last promotion relation----
 
   SELECT
    CASE
        WHEN hr_2.YearsSinceLastPromotion >= 0 AND hr_2.YearsSinceLastPromotion <= 10 THEN '1-10 Years'
        WHEN hr_2.YearsSinceLastPromotion >= 11 AND hr_2.YearsSinceLastPromotion <= 20 THEN '11-20 Years'
        WHEN hr_2.YearsSinceLastPromotion >= 21 AND hr_2.YearsSinceLastPromotion <= 30 THEN '21-30 Years'
        ELSE '30+ Years'
    END AS PromotionRange,
    ROUND(SUM(CASE WHEN hr_1.Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS AttritionRate
FROM
    hr_1 -- Assuming hr_1 is the table containing attrition rate information
INNER JOIN
    hr_2 -- Assuming hr_2 is the table containing years since last promotion
ON
    hr_1.EmployeeNumber = hr_2.Employee_ID -- Replace EmployeeID with the actual common identifier
GROUP BY
    PromotionRange
ORDER BY
    PromotionRange;
#*****************************************************************************************************************


