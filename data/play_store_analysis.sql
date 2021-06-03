/* App_Trader Query tool
PLAY
PLAY
PLAY
PLAY
PLAY
*/






/*SELECT*FROM play_store_apps
Limit 5*/
--PLAY STORE CTE AND DATA
WITH rating_conversion AS (SELECT *, 
						   ROUND(ROUND(rating * 2, 0)/2,1) AS rounded_rating
						  FROM play_store_apps),
	projected_lifespan AS(SELECT *,
							CASE WHEN rounded_rating = 0 OR rounded_rating IS NULL THEN 12
								WHEN rounded_rating = 0.5 THEN 24
								WHEN rounded_rating = 1.0 THEN 36
								WHEN rounded_rating = 1.5 THEN 48
								WHEN rounded_rating = 2.0 THEN 60
								WHEN rounded_rating = 2.5 THEN 72
								WHEN rounded_rating = 3.0 THEN 84
								WHEN rounded_rating = 3.5 THEN 96
								WHEN rounded_rating = 4.0 THEN 108
								WHEN rounded_rating = 4.5 THEN 120
								WHEN rounded_rating = 5.0 THEN 132
							END AS projected_lifespan_months
					  FROM rating_conversion),
	  Estimated_income_cost_1 AS (SELECT *,
							  		(projected_lifespan_months * 5000/2)::money AS est_income,
									(projected_lifespan_months * 1000)::money AS est_cost_after_purchase,
									 CASE WHEN  (price::money)::decimal <= 1 THEN 10000::money
									 	ELSE ((price::money)::decimal*10000)::money
									 END AS initial_cost	
							  	FROM projected_lifespan),
	Estimated_income_cost_data AS (SELECT *, 
								  		initial_cost + Est_cost_after_purchase AS est_total_cost,
								  		est_income - (initial_cost + Est_cost_after_purchase) AS expected_profit,
								   		ROUND((est_income::decimal/(initial_cost + Est_cost_after_purchase)::decimal)*100,2) AS percent_return
								   FROM estimated_income_cost_1)
--avg_percent_return by category								   
/*SELECT Category, ROUND(AVG(percent_return), 2) AS avg_percent_return
FROM Estimated_income_cost_data
GROUP BY category
ORDER BY avg_percent_return DESC
LIMIT 10;*/


--extra
/*SELECT name, price, review_count::decimal, rounded_rating, projected_lifespan_months, percent_return, expected_profit, genres
FROM Estimated_income_cost_data
	--AND prating = 4.5 
	--OR prating = 4.0
ORDER BY percent_return DESC, Review_count DESC;
*/

/*
--percentages of ratings for Play store
SELECT ROUND(ROUND(rating * 2, 0)/2,1) AS rounded_rating,
		COUNT(rating),
		ROUND(ROUND((COUNT(rating)/(SELECT COUNT(*) FROM play_store_apps)::numeric)*100,2)/2,1) AS percent_of_all_ratings
FROM play_store_apps
GROUP BY rounded_rating
ORDER BY percent_of_all_ratings DESC;*/

--apps with 4 and 4.5 stars make up a nearly 60% of all apps and therefore would be a great longevity range to pursue
--Look at returns for apps with either 4 or 4.5 stars



/*
--Look at rate of return
--percentages of category for PLAY
SELECT category,
		COUNT(category),
		ROUND((COUNT(category)/(SELECT COUNT(*) FROM play_Store_apps)::numeric)*100,2) AS percent_of_all_genres
FROM play_store_apps
GROUP BY category
ORDER BY percent_of_all_genres DESC
LIMIT 10;*/


/*SELECT 
		CASE WHEN Price::money::decimal <= 1 Then '$1 or less'
			WHEN price::money::decimal <= 2 Then 'btw $1 and $2'
			ELSE 'greater than $2'
			END AS Price_category,
		ROUND(AVG(percent_return), 1) AS avg_percent_return
FROM Estimated_income_cost_data
GROUP BY price_category
ORDER BY avg_percent_return DESC
LIMIT 10;
*/
/*
--count of price category 
price_category_count AS(SELECT 
		CASE WHEN Price::money::decimal <= 1 Then '$1 or less'
			WHEN price::money::decimal <= 2 Then 'btw $1 and $2'
			ELSE 'greater than $2'
			END AS Price_category
			FROM Estimated_income_cost_data)
SELECT price_category, COUNT(price_category)
FROM price_category_count
GROUP by price_category*/
		
/*		ROUND(AVG(percent_return), 1) AS avg_percent_return
FROM Estimated_income_cost_data
GROUP BY price_category
ORDER BY avg_percent_return DESC
LIMIT 10;
*/


SELECT 
		content_rating,
		ROUND(AVG(percent_return), 1) AS avg_percent_return
FROM Estimated_income_cost_data
GROUP BY content_rating
ORDER BY avg_percent_return DESC
LIMIT 10;