-- Retrieve the total number of leads in the dataset.
SELECT 
	COUNT(id) as total_number_of_leads
FROM real_estate.lead;

-- Find the average budget specified by potential buyers.
SELECT AVG(budget) AS avg_budget_of_buyers
FROM real_estate.lead
WHERE buyer=true

-- Identify the top 5 locations with the highest number of leads.
SELECT 
	location, 
	COUNT(id) as total_leads
FROM real_estate.lead
WHERE location IS NOT NULL
GROUP BY location
ORDER BY total_leads desc
LIMIT 5;

-- Retrieve the unique lead types along with the count of leads for each type.
SELECT
	 lt.lead_type,
	COUNT(l.id) AS total_leads
FROM real_estate.lead l LEFT JOIN real_estate.lead_type lt ON l.lead_type_id=lt.id
GROUP BY lt.lead_type
ORDER BY total_leads desc;

-- What is the distribution of leads among different lead types, and how does it impact the overall sales conversion rate?
--1 we get in the previous query the number of leads per lead_type
--2 we will get the number of sales per lead_type
WITH total_leads AS(
	SELECT
		lt.lead_type,
		COUNT(l.id) AS total_leads
	FROM real_estate.lead l LEFT JOIN real_estate.lead_type lt ON l.lead_type_id=lt.id
	GROUP BY lt.lead_type
),
total_sales AS(
	SELECT
		lt.lead_type,
		COUNT(*) as total_sales
	FROM real_estate.sale s LEFT JOIN real_estate.lead l ON s.lead_id=l.id  
		LEFT JOIN real_estate.lead_type lt ON l.lead_type_id=lt.id
	GROUP BY lt.lead_type
)
SELECT
	l.lead_type,
	l.total_leads,
	s.total_sales,
   ((s.total_sales :: FLOAT) / l.total_leads)*100 as sale_conversion_rate
FROM total_leads l LEFT JOIN total_sales s ON l.lead_type=s.lead_type
ORDER BY l.total_leads desc;

-- Find the top 3 lead sources with the highest number of leads.
SELECT 
	lead_source, 
	COUNT(id) as total_leads
FROM real_estate.lead
WHERE location IS NOT NULL
GROUP BY lead_source
ORDER BY total_leads desc
LIMIT 3;

-- Retrieve the total number of sales in the dataset.
SELECT COUNT(distinct id) AS total_sales
FROM real_estate.sale

-- Find the total value of sales and the average value per unit.
SELECT
	unit_location,
	SUM(unit_value) AS total_value_of_sales,
	AVG(unit_value) AS avg_value_of_sales,
	COUNT(Id) as count_number_of_sales
FROM real_estate.sale
WHERE unit_value IS NOT NULL
GROUP BY unit_location
ORDER BY count_number_of_sales desc;

--  Identify the top 3 sales agents (by user_id) based on the total value of the deals they closed.
SELECT
	user_id,
	SUM(unit_value) AS total_value_of_sales
FROM real_estate.sale s LEFT JOIN real_estate.lead l on s.lead_id=l.id
WHERE unit_value IS NOT NULL
GROUP BY user_id
ORDER BY total_value_of_sales DESC
LIMIT 3;

-- Find the top 3 lead sources with the highest number of successful sales.
SELECT
	lead_source,
	COUNT(*) AS total_sales
FROM real_estate.sale s LEFT JOIN real_estate.lead l on s.lead_id=l.id
GROUP BY lead_source
ORDER BY total_sales DESC
LIMIT 3;

-- For each sales agent (user_id), calculate the total value of deals closed
SELECT
	user_id AS sales_agent,
	SUM(unit_value) AS total_value_of_sales,
	COUNT(s.id) AS total_number_of_sales_deals 
FROM real_estate.sale s LEFT JOIN real_estate.lead l on s.lead_id=l.id
GROUP BY user_id
ORDER BY total_number_of_sales_deals DESC

--	Calculate the percentage difference between the expected and actual values for each sale.
SELECT
	id as sale_id,
	expected_value,
	actual_value,
	((actual_value - expected_value) / expected_value)*100 as percentage_of_difference
FROM real_estate.sale
WHERE expected_value IS NOT NULL AND actual_value IS NOT NULL;
-- WE CAN use  unit_value as its actual value:
SELECT
	id as sale_id,
	expected_value,
	unit_value,
	((unit_value - expected_value) / expected_value)*100 as percentage_of_difference
FROM real_estate.sale
WHERE expected_value IS NOT NULL AND unit_value IS NOT NULL;


-- What is the distribution of properties among different property types, and how does it impact the overall sales performance?
SELECT
	property_type,
	COUNT(*) AS total_number_of_sales,
	SUM(unit_value) AS total_sales_value 
FROM real_estate.sale s LEFT JOIN real_estate.property_type p ON s.property_type_id=p.id
WHERE property_type IS NOT NULL
GROUP BY property_type
ORDER BY total_number_of_sales DESC;

-- What is the conversion rate from leads to sales, and how does it vary among different lead types?
WITH total_leads AS(
	SELECT
		lt.lead_type,
		COUNT(l.id) AS total_leads
	FROM real_estate.lead l LEFT JOIN real_estate.lead_type lt ON l.lead_type_id=lt.id
	GROUP BY lt.lead_type
),
total_sales AS(
	SELECT
		lt.lead_type,
		COUNT(*) as total_sales
	FROM real_estate.sale s LEFT JOIN real_estate.lead l ON s.lead_id=l.id  
		LEFT JOIN real_estate.lead_type lt ON l.lead_type_id=lt.id
	GROUP BY lt.lead_type
)
SELECT
	l.lead_type,
	l.total_leads,
	s.total_sales,
   ((s.total_sales :: FLOAT) / l.total_leads)*100 as sale_conversion_rate
FROM total_leads l LEFT JOIN total_sales s ON l.lead_type=s.lead_type
ORDER BY l.total_leads desc;

--	Are there specific lead types that tend to have higher budgets, and how can this information inform sales strategies?
SELECT
	lead_type,
	SUM(budget) as total_budget
FROM real_estate.lead l LEFT JOIN real_estate.lead_type lt ON l.lead_type_id=lt.id
GROUP BY lead_type
ORDER BY total_budget DESC;

-- For each lead type, find the sales agent (user_id) with the highest total value of deals closed.
SELECT
	lead_type,
	sales_agent,
	total_sales_value
FROM (
SELECT
	lead_type,
	user_id as sales_agent,
	SUM(unit_value) as total_sales_value,
	ROW_NUMBER() OVER(PARTITION BY lead_type ORDER BY SUM(unit_value) DESC) AS num_row
FROM real_estate.sale s LEFT JOIN real_estate.lead l ON s.lead_id = l.id 
    LEFT JOIN real_estate.lead_type lt ON lt.id = l.lead_type_id
WHERE unit_value IS NOT NULL
GROUP BY lead_type,
		user_id) numbering_rows_as_ranked
WHERE num_row=1
ORDER BY total_sales_value;
		
--	What is the distribution of properties among different property types, and how does it impact the overall sales performance?
SELECT
	property_type,
	COUNT(*) AS total_number_of_sales,
	SUM(unit_value) AS total_sales_value 
FROM real_estate.sale s LEFT JOIN real_estate.property_type p ON s.property_type_id=p.id
WHERE property_type IS NOT NULL
GROUP BY property_type
ORDER BY total_number_of_sales DESC;

--	For each property type, find the sales agent (user_id) with the highest total value of deals closed.
SELECT
	property_type,
	sales_agent,
	total_sales_value
FROM (
SELECT
	property_type,
	user_id as sales_agent,
	SUM(unit_value) as total_sales_value,
	ROW_NUMBER() OVER(PARTITION BY property_type ORDER BY SUM(unit_value) DESC) AS num_row
FROM real_estate.sale s LEFT JOIN real_estate.lead l ON s.lead_id = l.id 
	LEFT JOIN real_estate.property_type p ON s.property_type_id=p.id
WHERE unit_value IS NOT NULL
GROUP BY property_type,
		user_id) numbering_rows_as_ranked
WHERE num_row=1
ORDER BY total_sales_value DESC;

--Are there specific property types that tend to have higher actual values in sales, and how can this information inform marketing strategies?
SELECT
	property_type ,
	SUM(expected_value) AS total_expected_value,
	SUM(actual_value) AS total_actual_value,
	(((SUM(actual_value) - SUM(expected_value)) / SUM(expected_value)) * 100) as percentage_of_difference
FROM real_estate.sale s LEFT JOIN real_estate.property_type p ON s.property_type_id=p.id
WHERE expected_value IS NOT NULL AND actual_value IS NOT NULL
GROUP BY property_type
ORDER BY total_actual_value DESC;