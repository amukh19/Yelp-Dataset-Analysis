--How many reviewers are in the dataset?
Select count(user_id)
from review;

--How many are elite members?
select count(elite)
from user;

--How are the review being distributed over time?
SELECT STRFTIME('%Y', date) AS Year, Count(*)
FROM review
GROUP BY Year;

--Finding the oldest date in yelping_since column
Select MIN(yelping_since) as oldest_date
from user;

--Finding the recent date in yelping_since column
Select MAX(yelping_since) as newest_date
from user;

--How long have the elite members been members since?
--plugging the dates found above into here to find the tenure of the elite users
SELECT elite, AVG(STRFTIME('%Y', '2005-03-08') - STRFTIME('%Y', yelping_since)) AS avg_years_since_joined
FROM user
WHERE elite IS NOT NULL
ORDER BY avg_years_since_joined;

--Top Ten users with most fans to find correlation between the number of reviews a user gives vs fan base
SELECT name, fans, review_count
FROM user
ORDER BY fans desc
limit 5;

--Does the number of votes (funny, useful, compliments) equals more fans?
SELECT name, fans, count(text) as numreviews, average_stars, user.funny, user.useful, compliment_hot, compliment_funny
FROM user JOIN review USING (user_id)
GROUP BY "user_id"
ORDER BY fans desc
LIMIT 5;

--What about people with less fans?
SELECT name, fans, count(text) as numreviews, average_stars, user.funny, user.useful, compliment_hot, compliment_funny
FROM user JOIN review USING (user_id)
WHERE fans <= 50
GROUP BY "user_id"
ORDER BY fans desc
LIMIT 5;
