--Which Business has the Least Number of Reviews and How Many Reviews Does It Have?

SELECT b.business_id, b.name, COUNT(r.review_id) AS review_count
FROM review r
JOIN business b ON r.business_id = b.business_id
GROUP BY b.business_id, b.name
ORDER BY review_count ASC
LIMIT 1;
  
--Number of Reviews per Rating Category
SELECT stars AS rating, COUNT(*) AS review_count
FROM review
GROUP BY stars
ORDER BY stars;

--Number of Reviews per City of Business
SELECT b.city, COUNT(r.review_id) AS total_reviews
FROM review r
JOIN business b ON r.business_id = b.business_id
GROUP BY b.city
ORDER BY total_reviews DESC;


--Which Businesses Have 5 Star Reviews?
SELECT DISTINCT b.business_id, b.name
FROM review r
JOIN business b ON r.business_id = b.business_id
WHERE r.stars = 5;

