/* App_Trader Query tool
BOTH
BOTH
BOTH
BOTH
BOTH
BOTH
*/



WITH on_both_stores AS(SELECT DISTINCT a.name AS aname, 
					   					a.price::money AS aprice,
					   					ROUND(ROUND(a.rating * 2, 0)/2,1) AS arating, 
					   					a.review_count AS areview, a.primary_genre AS agenre,
					   		  			p.name AS pname, p.price::money AS pprice, 
					   					ROUND(ROUND(p.rating * 2, 0)/2,1) AS prating, 
					   					p.content_rating AS pcontent_rating, 
					   					p.category AS pcategory
								FROM app_store_apps AS a 
					   				INNER JOIN play_store_apps AS p
		 								ON a.name=p.name),
--SELECT DISTINCT * FROM on_both_stores;
	rating_conversion AS (SELECT *, 
						   ROUND(ROUND(((arating + prating)/2) * 2, 0)/2,1) AS avg_rounded_rating
						  FROM on_both_stores),
	projected_lifespan AS(SELECT *,
							CASE WHEN avg_rounded_rating = 0 OR avg_rounded_rating IS NULL THEN 12
								WHEN avg_rounded_rating = 0.5 THEN 24
								WHEN avg_rounded_rating = 1.0 THEN 36
								WHEN avg_rounded_rating = 1.5 THEN 48
								WHEN avg_rounded_rating = 2.0 THEN 60
								WHEN avg_rounded_rating = 2.5 THEN 72
								WHEN avg_rounded_rating = 3.0 THEN 84
								WHEN avg_rounded_rating = 3.5 THEN 96
								WHEN avg_rounded_rating = 4.0 THEN 108
								WHEN avg_rounded_rating = 4.5 THEN 120
								WHEN avg_rounded_rating = 5.0 THEN 132
							END AS projected_lifespan_months
					  FROM rating_conversion),
	  Estimated_income_cost_1 AS (SELECT *,
							  		(projected_lifespan_months * 5000/2)::money AS est_income,
									(projected_lifespan_months * 1000)::money AS est_cost_after_purchase,
									 CASE WHEN  (aprice::money)::decimal <= 1 THEN 10000::money
									 	ELSE ((aprice::money)::decimal*10000)::money
									 END AS initial_acost,
								  	CASE WHEN  (pprice::money)::decimal <= 1 THEN 10000::money
									 	ELSE ((pprice::money)::decimal*10000)::money
									 END AS initial_pcost
							  	FROM projected_lifespan),
	Estimated_income_cost_data AS (SELECT *, 
								   		initial_pcost + initial_acost AS initial_cost,
								  		(initial_pcost + initial_acost) + Est_cost_after_purchase AS est_total_cost,
								  		est_income - ((initial_pcost + initial_acost) + Est_cost_after_purchase) AS expected_profit,
								   		ROUND((est_income::decimal/((initial_pcost + initial_acost) + Est_cost_after_purchase)::decimal)*100,2) AS percent_return
								   FROM estimated_income_cost_1)
SELECT COUNT(*)
FROM Estimated_income_cost_data
/* avg_percent_return by genre
SELECT agenre, ROUND(AVG(percent_return), 2) AS avg_percent_return
FROM Estimated_income_cost_data
GROUP BY agenre
ORDER BY avg_percent_return DESC;*/
				  							  
/*SELECT aname, 
		aprice, 
		pprice, 
		avg_rounded_rating, 
		projected_lifespan_months, 
		initial_cost,
		percent_return, expected_profit
FROM Estimated_income_cost_data
	--AND prating = 4.5 
	--OR prating = 4.0
ORDER BY percent_return DESC;*/



/*percentages of ratings for Play store
SELECT avg_rounded_rating,
		COUNT(avg_rounded_rating),
		ROUND(ROUND((COUNT(avg_rounded_rating)/(SELECT COUNT(*) FROM Estimated_income_cost_data)::numeric)*100,2)/2,1) AS percent_of_all_ratings
FROM Estimated_income_cost_data
GROUP BY avg_rounded_rating
ORDER BY percent_of_all_ratings DESC;*/

--apps with 4 and 4.5 stars make up a nearly 60% of all apps and therefore would be a great longevity range to pursue
--Look at returns for apps with either 4 or 4.5 stars



/*
--Look at rate of return
--percentages of category for PLAY
SELECT pcategory,
		COUNT(pcategory),
		ROUND((COUNT(pcategory)/(SELECT COUNT(*) FROM Estimated_income_cost_data)::numeric)*100,2) AS percent_of_all_genres
FROM Estimated_income_cost_data
GROUP BY pcategory
ORDER BY percent_of_all_genres DESC
LIMIT 10;
*/
/*
-- Top 10 Apps Data
SELECT aname,
		pcontent_rating,
		avg_rounded_rating,
		projected_lifespan_months/12 AS projected_lifespan_years, 
		expected_profit,
		percent_return
FROM Estimated_income_cost_data
WHERE aname ILIKE '%Southwest%'
OR aname ILIKE '%AirBNB%'
OR aname ILIKE 'Instagram%'
OR aname ILIKE '%Facebook%'
OR aname ILIKE '%Uber'
OR aname ILIKE '%Domino_s%'
OR aname ILIKE '%Starbucks%'
OR aname ILIKE '%Doordash%'
OR aname ILIKE '%Youtube%'
OR aname ILIKE '%Design Home%'
OR aname ILIKE '%Fandango%' 
ORDER BY percent_return DESC;
*/

/*SELECT 
		CASE WHEN aPrice::decimal <= 1 Then '$1 or less'
			WHEN aprice::decimal > 1 Then aprice::text
			 WHEN pPrice::money::decimal <= 1 Then '$1 or less'
			WHEN pprice::money::decimal > 1 Then pprice::text
			END AS Price_category,
		ROUND(AVG(percent_return), 1) AS avg_percent_return
FROM Estimated_income_cost_data
GROUP BY price_category
ORDER BY avg_percent_return DESC
LIMIT 10;*/

SELECT 
		pcontent_rating,
		ROUND(AVG(percent_return), 1) AS avg_percent_return
FROM Estimated_income_cost_data
GROUP BY pcontent_rating
ORDER BY avg_percent_return DESC
LIMIT 10;


