-- Introduction:
-- This document is designed to understand the behavious of the Customer "Dunder Mifflin" with ororganization_id=4, who has suspected there is an increase
-- in the utilization of the dialogue's servies and if the increase is true, understand why has caused this ascending movement in utilization

-- Requirements:
-- Analyze Dunder Mifflin's utilization and financial profile.
-- Provide Laura with information for client support and decision-making.
-- Perform a full analysis, document data exploration, and present results as a customer presentation.
-- Highlight utilization trends and potential root causes for changes.
-- Provide gross margin profile based on 2023 actual costs and revenue and Include projections for 2024.


-- Analysis:
select * from cost_to_serve_monthly ;
Select COUNT(*) from cost_to_serve_monthly;
select * from episodes ;
Select COUNT(*) from episodes;
SELECT DISTINCT(episodes."PROGRAM") from episodes where episodes."ORGANIZATION_ID"=4;
select * from  organizations_monthly;
Select COUNT(*) from organizations_monthly;

-- Finding the utilization rate of services in 2023
SELECT
	episodes."ORGANIZATION_ID" as Org_id,
  	Count(episodes."EPISODE_CREATED_AT") as total_episodes,
  	avg(organizations_monthly."ELIGIBLE_MEMBERS") as members,
  	round((Count(episodes."EPISODE_CREATED_AT")/avg(organizations_monthly."ELIGIBLE_MEMBERS")), 2) as utilization_rate
from 
	episodes
join organizations_monthly ON
  	episodes."ORGANIZATION_ID" = organizations_monthly."ORGANIZATION_ID"
where 
  	EXTRACT(YEAR FROM episodes."EPISODE_CREATED_AT"::TIMESTAMP) = 2023
    AND episodes."ORGANIZATION_ID" = 4
GROUP By 
  	episodes."ORGANIZATION_ID" 
order by 
  	episodes."ORGANIZATION_ID";

-- Understanding What is the Cost to server the customer in all programs
--- PROGRAM = 'primary_care'
WITH CTS AS (
  SELECT
    e."PROGRAM",
    e."OUTCOME",
    ct."COST_TO_SERVE_PRIMARY_CARE",
    ct."COST_TO_SERVE_MENTAL_HEALTH",
    ct."COST_TO_SERVE_EAP",
    COUNT(e."EPISODE_CREATED_AT") AS Total_episodes,
    SUM(ct."COST_TO_SERVE_PRIMARY_CARE") AS Total_cost_Primary_care,
    ROUND(SUM(ct."COST_TO_SERVE_PRIMARY_CARE":: NUMERIC) / COUNT(e."EPISODE_CREATED_AT"), 2) AS Cost_to_serve_per_episode
  FROM
    cost_to_serve_monthly ct
  JOIN episodes e ON
    EXTRACT(YEAR FROM e."EPISODE_CREATED_AT"::TIMESTAMP) = EXTRACT(YEAR FROM ct."DATE_MONTH"::TIMESTAMP)
    AND EXTRACT(MONTH FROM e."EPISODE_CREATED_AT"::TIMESTAMP) = EXTRACT(MONTH FROM ct."DATE_MONTH"::TIMESTAMP)
  WHERE
    EXTRACT(YEAR FROM e."EPISODE_CREATED_AT"::TIMESTAMP) = 2023
    AND e."ORGANIZATION_ID" = 4
  GROUP BY
    e."PROGRAM", e."OUTCOME",ct."COST_TO_SERVE_PRIMARY_CARE",
    ct."COST_TO_SERVE_MENTAL_HEALTH",
    ct."COST_TO_SERVE_EAP")
SELECT
	Total_cost_Primary_care,
    Total_episodes,
    Cost_to_serve_per_episode
FROM
	CTS
Where 
	CTS."PROGRAM" = 'primary_care'
ORDER BY
	Total_episodes 
    
--- PROGRAM = 'mental_health'
WITH CTS AS (
  SELECT
    e."PROGRAM",
    e."OUTCOME",
    ct."COST_TO_SERVE_PRIMARY_CARE",
    ct."COST_TO_SERVE_MENTAL_HEALTH",
    ct."COST_TO_SERVE_EAP",
    COUNT(e."EPISODE_CREATED_AT") AS Total_episodes,
    SUM(ct."COST_TO_SERVE_PRIMARY_CARE") AS Total_cost_Primary_care,
    ROUND(SUM(ct."COST_TO_SERVE_PRIMARY_CARE":: NUMERIC) / COUNT(e."EPISODE_CREATED_AT"), 2) AS Cost_to_serve_per_episode
  FROM
    cost_to_serve_monthly ct
  JOIN episodes e ON
    EXTRACT(YEAR FROM e."EPISODE_CREATED_AT"::TIMESTAMP) = EXTRACT(YEAR FROM ct."DATE_MONTH"::TIMESTAMP)
    AND EXTRACT(MONTH FROM e."EPISODE_CREATED_AT"::TIMESTAMP) = EXTRACT(MONTH FROM ct."DATE_MONTH"::TIMESTAMP)
  WHERE
    EXTRACT(YEAR FROM e."EPISODE_CREATED_AT"::TIMESTAMP) = 2023
    AND e."ORGANIZATION_ID" = 4
  GROUP BY
    e."PROGRAM", e."OUTCOME",ct."COST_TO_SERVE_PRIMARY_CARE",
    ct."COST_TO_SERVE_MENTAL_HEALTH",
    ct."COST_TO_SERVE_EAP")
SELECT
	Total_cost_Primary_care,
    Total_episodes,
    Cost_to_serve_per_episode
FROM
	CTS
Where 
	CTS."PROGRAM" = 'mental_health'
ORDER BY
	Total_episodes 
    
--- PROGRAM = 'eap'
WITH CTS AS (
  SELECT
    e."PROGRAM",
    e."OUTCOME",
    ct."COST_TO_SERVE_PRIMARY_CARE",
    ct."COST_TO_SERVE_MENTAL_HEALTH",
    ct."COST_TO_SERVE_EAP",
    COUNT(e."EPISODE_CREATED_AT") AS Total_episodes,
    SUM(ct."COST_TO_SERVE_PRIMARY_CARE") AS Total_cost_Primary_care,
    ROUND(SUM(ct."COST_TO_SERVE_PRIMARY_CARE":: NUMERIC) / COUNT(e."EPISODE_CREATED_AT"), 2) AS Cost_to_serve_per_episode
  FROM
    cost_to_serve_monthly ct
  JOIN episodes e ON
    EXTRACT(YEAR FROM e."EPISODE_CREATED_AT"::TIMESTAMP) = EXTRACT(YEAR FROM ct."DATE_MONTH"::TIMESTAMP)
    AND EXTRACT(MONTH FROM e."EPISODE_CREATED_AT"::TIMESTAMP) = EXTRACT(MONTH FROM ct."DATE_MONTH"::TIMESTAMP)
  WHERE
    EXTRACT(YEAR FROM e."EPISODE_CREATED_AT"::TIMESTAMP) = 2023
    AND e."ORGANIZATION_ID" = 4
  GROUP BY
    e."PROGRAM", e."OUTCOME",ct."COST_TO_SERVE_PRIMARY_CARE",
    ct."COST_TO_SERVE_MENTAL_HEALTH",
    ct."COST_TO_SERVE_EAP")
SELECT
	Total_cost_Primary_care,
    Total_episodes,
    Cost_to_serve_per_episode
FROM
	CTS
Where 
	CTS."PROGRAM" = 'eap'
ORDER BY
	Total_episodes 
    
-- Analyzing the financial profile of the customer
WITH Costs AS (
    SELECT
        cm."DATE_MONTH",
        cm."COST_TO_SERVE_PRIMARY_CARE",
        cm."COST_TO_SERVE_MENTAL_HEALTH",
        cm."COST_TO_SERVE_EAP",
        om."ELIGIBLE_MEMBERS"
    FROM
      cost_to_serve_monthly cm
    JOIN episodes e ON
      EXTRACT(YEAR FROM e."EPISODE_CREATED_AT"::TIMESTAMP) = EXTRACT(YEAR FROM cm."DATE_MONTH"::TIMESTAMP)
      AND EXTRACT(MONTH FROM e."EPISODE_CREATED_AT"::TIMESTAMP) = EXTRACT(MONTH FROM cm."DATE_MONTH"::TIMESTAMP)
  	JOIN organizations_monthly om ON
  		e."ORGANIZATION_ID"= om."ORGANIZATION_ID" 	
    WHERE
        e."ORGANIZATION_ID" = 4
        AND EXTRACT(YEAR FROM cm."DATE_MONTH"::TIMESTAMP) = 2023)
SELECT
    DATE_TRUNC('MONTH', c."DATE_MONTH"::TIMESTAMP) AS Month,
    c."DATE_MONTH" AS Date_Month,
    SUM(c."COST_TO_SERVE_PRIMARY_CARE") AS Total_Cost_Primary_Care,
    SUM(c."COST_TO_SERVE_MENTAL_HEALTH") AS Total_Cost_Mental_Health,
    SUM(c."COST_TO_SERVE_EAP") AS Total_Cost_EAP,
    SUM(c."COST_TO_SERVE_PRIMARY_CARE" + c."COST_TO_SERVE_MENTAL_HEALTH" + c."COST_TO_SERVE_EAP") AS Total_Cost_All_Programs,
    AVG(c."ELIGIBLE_MEMBERS") AS Avg_Eligible_Members
FROM
    Costs c
GROUP BY
    Month, Date_Month
ORDER BY
    Month,Total_Cost_All_Programs;


-- Identifying the trends by calculating the month on month Utilization rate 
SELECT
    DATE_TRUNC('month', e."EPISODE_CREATED_AT"::TIMESTAMP) AS month,
    COUNT(e."EPISODE_ID") AS total_episodes,
    round(AVG(om."ELIGIBLE_MEMBERS") ,2)AS avg_eligible_members,
    round((COUNT(e."EPISODE_ID") / AVG(om."ELIGIBLE_MEMBERS")*100),2) AS utilization_rate
FROM
    episodes e
JOIN
    organizations_monthly om ON e."ORGANIZATION_ID" = om."ORGANIZATION_ID"
WHERE
    e."ORGANIZATION_ID" = 4
    AND EXTRACT(YEAR FROM  e."EPISODE_CREATED_AT"::TIMESTAMP) >= 2023  
GROUP BY
    month
ORDER BY
    month;
 
-- There is a clear spike in the utilization rate from the month of May(2023-05)
select 
	MIN(SUBSTRING(om."HAS_PRIMARY_CARE_SINCE" FROM '\d{4}-\d{2}-\d{2}')) AS starting_date_primary_care,
    MIN(SUBSTRING(om."HAS_MENTAL_HEALTH_SINCE" FROM '\d{4}-\d{2}-\d{2}')) AS starting_date_mental_heallth,
    MIN(SUBSTRING(om."HAS_EAP_SINCE" FROM '\d{4}-\d{2}-\d{2}')) AS starting_date_eap
from 
	organizations_monthly om
where 
	om."ORGANIZATION_ID" = 4;    
    
-- Understanding change in utilization_rate the root cause by exploring different dimensions
--- Exploring the utilization_rate by program
SELECT
   e."PROGRAM",
    COUNT(e."EPISODE_ID") AS total_episodes,
    round(AVG(om."ELIGIBLE_MEMBERS") ,2)AS avg_eligible_members,
    round((COUNT(e."EPISODE_ID") / AVG(om."ELIGIBLE_MEMBERS")*100),2) AS utilization_rate
FROM
    episodes e
JOIN
    organizations_monthly om ON e."ORGANIZATION_ID" = om."ORGANIZATION_ID"
WHERE
    e."ORGANIZATION_ID" = 4
    AND EXTRACT(YEAR FROM  e."EPISODE_CREATED_AT"::TIMESTAMP) >= 2023  
GROUP BY
    e."PROGRAM"
ORDER BY
   utilization_rate desc;

--- Exploring the utilization_rate by outcome
SELECT
    e."OUTCOME",
    COUNT(e."EPISODE_ID") AS total_episodes,
    round(AVG(om."ELIGIBLE_MEMBERS") ,2)AS avg_eligible_members,
    round((COUNT(e."EPISODE_ID") / AVG(om."ELIGIBLE_MEMBERS")*100),2) AS utilization_rate
FROM
    episodes e
JOIN
    organizations_monthly om ON e."ORGANIZATION_ID" = om."ORGANIZATION_ID"
WHERE
    e."ORGANIZATION_ID" = 4
    AND EXTRACT(YEAR FROM  e."EPISODE_CREATED_AT"::TIMESTAMP) >= 2023  
GROUP BY
     e."OUTCOME"
ORDER BY
     utilization_rate desc;
     
     
-- Calculating the total cost and total revenue to find the gross margins
--- Assuming the reveune is 0 due to insuffcient information
WITH Costs_2023 AS (
    SELECT
        e."ORGANIZATION_ID",
        SUM(ct."COST_TO_SERVE_PRIMARY_CARE") AS total_cost_primary_care,
        SUM(ct."COST_TO_SERVE_MENTAL_HEALTH") AS total_cost_mental_health,
        SUM(ct."COST_TO_SERVE_EAP") AS total_cost_eap,
  		(SUM(ct."COST_TO_SERVE_PRIMARY_CARE")+SUM(ct."COST_TO_SERVE_MENTAL_HEALTH")+SUM(ct."COST_TO_SERVE_EAP")) as total_cost_2023
    FROM
    	cost_to_serve_monthly ct
  	JOIN episodes e ON
    	EXTRACT(YEAR FROM e."EPISODE_CREATED_AT"::TIMESTAMP) = EXTRACT(YEAR FROM ct."DATE_MONTH"::TIMESTAMP)
    	AND EXTRACT(MONTH FROM e."EPISODE_CREATED_AT"::TIMESTAMP) = EXTRACT(MONTH FROM ct."DATE_MONTH"::TIMESTAMP)
  	WHERE
    	EXTRACT(YEAR FROM e."EPISODE_CREATED_AT"::TIMESTAMP) = 2023
    	AND e."ORGANIZATION_ID" = 4
    GROUP BY
        "ORGANIZATION_ID"),
 
Revenue_2023 as (
      	SELECT
            e."ORGANIZATION_ID",
            0 AS total_revenue_2023
        FROM
            episodes e
        WHERE
            e."ORGANIZATION_ID" = 4
            AND EXTRACT(YEAR FROM "EPISODE_CREATED_AT"::TIMESTAMP) = 2023
        GROUP BY
            "ORGANIZATION_ID")
SELECT
    c."ORGANIZATION_ID",
    c.total_cost_2023,
    r.total_revenue_2023,
    (r.total_revenue_2023 - c.total_cost_2023) AS gross_margin_2023
FROM
    Costs_2023 c
JOIN
    Revenue_2023 r ON c."ORGANIZATION_ID" = r."ORGANIZATION_ID";
    
-- Using the caluculated total cost and total revenue, Projecting the gross margin for 2024 (assuming the total increase in cost is 5% and total revenue grew by 10% as per market standards) 
WITH Costs_2023 AS (
    SELECT
        e."ORGANIZATION_ID",
        SUM(ct."COST_TO_SERVE_PRIMARY_CARE") AS total_cost_primary_care,
        SUM(ct."COST_TO_SERVE_MENTAL_HEALTH") AS total_cost_mental_health,
        SUM(ct."COST_TO_SERVE_EAP") AS total_cost_eap,
  		(SUM(ct."COST_TO_SERVE_PRIMARY_CARE")+SUM(ct."COST_TO_SERVE_MENTAL_HEALTH")+SUM(ct."COST_TO_SERVE_EAP")) as total_cost_2023
    FROM
    	cost_to_serve_monthly ct
  	JOIN episodes e ON
    	EXTRACT(YEAR FROM e."EPISODE_CREATED_AT"::TIMESTAMP) = EXTRACT(YEAR FROM ct."DATE_MONTH"::TIMESTAMP)
    	AND EXTRACT(MONTH FROM e."EPISODE_CREATED_AT"::TIMESTAMP) = EXTRACT(MONTH FROM ct."DATE_MONTH"::TIMESTAMP)
  	WHERE
    	EXTRACT(YEAR FROM e."EPISODE_CREATED_AT"::TIMESTAMP) = 2023
    	AND e."ORGANIZATION_ID" = 4
    GROUP BY
        "ORGANIZATION_ID"),
 
Revenue_2023 as (
      	SELECT
            e."ORGANIZATION_ID",
            0 AS total_revenue_2023
        FROM
            episodes e
        WHERE
            e."ORGANIZATION_ID" = 4
            AND EXTRACT(YEAR FROM "EPISODE_CREATED_AT"::TIMESTAMP) = 2023
        GROUP BY
            "ORGANIZATION_ID"),
Projected_Costs AS (
    SELECT
  		"ORGANIZATION_ID",
        total_cost_2023 * 1.05 AS projected_total_cost_2024
    FROM
        Costs_2023),
Projected_Revenues AS (
    SELECT
  		"ORGANIZATION_ID",
        total_revenue_2023 * 1.10 AS projected_total_revenue_2024
    FROM
        Revenue_2023)
SELECT
    pc.projected_total_cost_2024,
    pr.projected_total_revenue_2024,
    (pr.projected_total_revenue_2024 - pc.projected_total_cost_2024) AS projected_gross_margin_2024
FROM
    Projected_Costs pc
JOIN
    Projected_Revenues pr ON pc."ORGANIZATION_ID" = pr."ORGANIZATION_ID";
    
--- Conclusion: 
-- Our analysis has substantiated a notable surge in the utilization of Dialogue's services by the esteemed client "Dunder Miflin", Organization id '4' in the year 
-- 2023 from the month of May(05) as the client has started subscribing to a new program "EAP" offered by Dialogue. As a result, the utilization rate has soared by more 
-- than 100% from the comencement of the new service. However this increase has created a significant impact of the costs to serve and this necessitates a reevaluation 
-- of service allocation strategies to optimize operational efficiencies and cost-effectiveness