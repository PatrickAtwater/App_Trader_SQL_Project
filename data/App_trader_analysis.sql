/* App_Trader Query tool*/




/*FROM ERIC

SELECT distinct combined.name, 
		--CAST(AVG(new_jobs)AS DECIMAL(10,2))
		CAST(AVG(price::numeric)AS decimal(10,2))as price,
		CAST(AVG(rating)AS decimal(10,2)) AS rating, 
		CAST(AVG(review_count)AS decimal(10,2)) AS review_count
	FROM
		(SELECT name, rating, price::money, review_count::numeric
		FROM app_store_apps
		UNION ALL
		SELECT name, rating, price::money, review_count::numeric
		FROM play_store_apps) as combined
WHERE rating IS NOT NULL	
AND review_count >10000
AND price='0,00'
GROUP BY combined.name
ORDER BY rating desc;


*/
SELECT*
FROM App_store_apps
ORDER BY price DESC;

--look at apple, determine longevity of apps and compare with review count, price
/*
app lifespan: When 0 -> 1 year, .5 -> 2 years, 

WITH on_both_stores AS(SELECT a.name AS aname, a.price::money AS aprice, a.rating AS arating, a.review_count AS areview,
					   		  p.name AS pname, p.price::money AS pprice, p.rating AS prating, p.review_count AS preview
		FROM app_store_apps AS a INNER JOIN play_store_apps AS p
		 ON a.name=p.name)
	
SELECT aname, arating, prating, aprice, pprice
FROM on_both_stores;

*/
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
								   
				   

							  

SELECT name, price, review_count::decimal, rating, percent_return, expected_profit, primary_genre
FROM Estimated_income_cost_data
WHERE rating = 4.5 
	OR rating = 4.0
ORDER BY percent_return DESC, Review_count DESC;

-- ROUND to nearest .5 SELECT ROUND(ROUND(rating * 2, 0)/2,1)
SELECT COUNT(*) FROM APP_Store_apps;
--ratings by percent
SELECT rating, 
		COUNT(rating), 
		ROUND((COUNT(rating)/(SELECT COUNT(*) FROM APP_Store_apps)::numeric)*100,2) AS percent_of_all_ratings
FROM App_store_apps
GROUP BY rating
ORDER BY rating;

--apps with 4 and 4.5 stars make up a nearly 60% of all apps and therefore would be a great longevity range to pursue



--Look at returns for apps with either 4 or 4.5 stars




--Look at rate of return

SELECT primary_genre, 
		COUNT(primary_genre), 
		ROUND((COUNT(primary_genre)/(SELECT COUNT(*) FROM APP_Store_apps)::numeric)*100,2) AS percent_of_all_genres
FROM App_store_apps
GROUP BY primary_genre
ORDER BY percent_of_all_genres DESC
LIMIT 5;




WITH on_both_stores AS(SELECT DISTINCT a.name AS aname, 
					   					a.price::money AS aprice,
					   					ROUND(ROUND(a.rating * 2, 0)/2,1) AS arating, 
					   					a.review_count AS areview, a.primary_genre AS agenre,
					   		  			p.name AS pname, p.price::money AS pprice, 
					   					ROUND(ROUND(p.rating * 2, 0)/2,1) AS prating, 
					   					p.review_count AS preview, 
					   					p.genres AS pgenre
								FROM app_store_apps AS a 
					   				INNER JOIN play_store_apps AS p
		 								ON a.name=p.name)
SELECT DISTINCT * FROM on_both_stores;

--LOOK INTO ANY REASON TO PURSUE NON FREE APPS



