/* APPLE App_Trader Query tool
APPLE
APPLE
APPLE
APPLE*/

SELECT*
FROM App_store_apps
ORDER BY price DESC;

--look at apple, determine longevity of apps and compare with review count, price

WITH projected_lifespan AS (SELECT *,
							CASE WHEN rating = 0 THEN 12
								WHEN rating = 0.5 THEN 24
								WHEN rating = 1.0 THEN 36
								WHEN rating = 1.5 THEN 48
								WHEN rating = 2.0 THEN 60
								WHEN rating = 2.5 THEN 72
								WHEN rating = 3.0 THEN 84
								WHEN rating = 3.5 THEN 96
								WHEN rating = 4.0 THEN 108
								WHEN rating = 4.5 THEN 120
								WHEN rating = 5.0 THEN 132
							END AS projected_lifespan_months
					  FROM app_store_apps),
	  Estimated_income_cost_1 AS (SELECT *,
							  		(projected_lifespan_months * 5000/2)::money AS est_income,
									(projected_lifespan_months * 1000)::money AS est_cost_after_purchase,
									 CASE WHEN  price::decimal <= 1 THEN 10000::money
									 	ELSE (price::decimal*10000)::money
									 END AS initial_cost	
							  	FROM projected_lifespan),
	Estimated_income_cost_data AS (SELECT *, 
								  		initial_cost + Est_cost_after_purchase AS est_total_cost,
								  		est_income - (initial_cost + Est_cost_after_purchase) AS expected_profit,
								   		ROUND((est_income::decimal/(initial_cost + Est_cost_after_purchase)::decimal)*100,2) AS percent_return
								   FROM estimated_income_cost_1)
								   
/*SELECT primary_genre, ROUND(AVG(percent_return), 2) AS avg_percent_return
FROM Estimated_income_cost_data
GROUP BY primary_genre
ORDER BY avg_percent_return DESC
LIMIT 10;	*/						   

/*
--percentages of ratings for Apple store
SELECT rating, 
		COUNT(rating), 
		ROUND((COUNT(rating)/(SELECT COUNT(*) FROM APP_Store_apps)::numeric)*100,2) AS percent_of_all_ratings
FROM App_store_apps
GROUP BY rating
ORDER BY percent_of_all_ratings DESC;	*/			   

--apps with 4 and 4.5 stars make up a nearly 60% of all apps and therefore would be a great longevity range to pursue
--Look at returns for apps with either 4 or 4.5 stars
--Look at rate of return


/*
--percentages of genre for Apple
SELECT primary_genre, 
		COUNT(primary_genre), 
		ROUND((COUNT(primary_genre)/(SELECT COUNT(*) FROM APP_Store_apps)::numeric)*100,2) AS percent_of_all_genres
FROM App_store_apps
GROUP BY primary_genre
ORDER BY percent_of_all_genres DESC
LIMIT 5;*/

/*SELECT 
		CASE WHEN Price::decimal <= 1 Then '$1 or less'
			WHEN price::decimal > 1 Then price::text
			END AS Price_category,
		ROUND(AVG(percent_return), 1) AS avg_percent_return
FROM Estimated_income_cost_data
GROUP BY price_category
ORDER BY avg_percent_return DESC
LIMIT 10;*/

SELECT 
		content_rating,
		ROUND(AVG(percent_return), 1) AS avg_percent_return
FROM Estimated_income_cost_data
GROUP BY content_rating
ORDER BY avg_percent_return DESC
LIMIT 10;






