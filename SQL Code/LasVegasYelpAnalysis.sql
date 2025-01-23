--Base query to pull list of restaurants that fit the criteria:
create view lv_restaurant as
select b.name, b.business_id, b.stars, b.review_count, 
min(strftime('%Y-%m-%d', r.date)) as minDate, 
max(strftime('%Y-%m-%d', r.date)) as maxDate
from business b join review r using (business_id)
where city like 'Las Vegas' and b.review_count >= 1000 and 
categories LIKE '%restaurant%'
group by b.name
having maxDate - minDate >= 5
order by b.review_count desc;

-- Distribution of ratings
select stars, count(*) as amount, round(avg(review_count), 2) as avg_rev_count
from lv_restaurant
group by stars;

-- categorize the variables
create view lv_rc as
select *, case
   when stars >= 4 then 1
   else 0
   end as quality
from lv_restaurant;

-- base summary of difference
select quality, round(avg(review_count),2) as avg_rev_count, round(avg(stars), 2) as avg_stars
from lv_rc
group by quality;

-- location information
create temporary table lv_rest_loc as
select quality, neighborhood, count(*) as count
from lv_rest_exp
group by quality, neighborhood;

-- summary of neighborhood qualities 
SELECT neighborhood, SUM(poor) AS poor, SUM(good) AS good,
      ROUND(SUM(good)/ CAST((SUM(good) + SUM(poor)) AS REAL), 2) AS quality
FROM (SELECT neighborhood,
      CASE
          WHEN quality = 0 THEN count
          ELSE 0
      END AS poor,
      CASE
          WHEN quality = 1 THEN count
          ELSE 0
      END AS good
   FROM lv_rest_loc)
GROUP BY neighborhood; 

-- time open analysis
create temporary table lv_rest_time as
select name, business_id, quality,
   case
       when Monday = 'N/A' or Monday = '0:00-0:00' then 0
       else 1
       end as open_mon,
   case
       when Tuesday = 'N/A' or Tuesday = '0:00-0:00' then 0
       else 1
       end as open_tue,
   case
       when Wednesday = 'N/A' or Wednesday = '0:00-0:00' then 0
       else 1
       end as open_wed,     
   case
       when Thursday = 'N/A' or Thursday = '0:00-0:00' then 0
       else 1
       end as open_thu,
   case
       when Friday = 'N/A' or Friday = '0:00-0:00' then 0
       else 1
       end as open_fri
from lv_rest_exp;

-- proportion open by quality
select quality, round(cast(sum(open_mon) as real)/count(*), 2) as mon_open,
   round(cast(sum(open_tue) as real)/count(*), 2) as tue_open,
   round(cast(sum(open_wed) as real)/count(*), 2) as wed_open,
   round(cast(sum(open_thu) as real)/count(*), 2) as thu_open, 
   round(cast(sum(open_fri) as real)/count(*), 2)as fri_open
from lv_rest_time
group by quality;

-- photo count analysis
select quality, round(avg(NumPhotos), 2) as avg_pic_count
from lv_rest_exp
group by quality;

--Have users who reviewed restaurants in the base query list also have reviewed other restaurants in that list as well? 

create temporary table Restaurants as
   select b.name, b.business_id, b.stars, b.review_count, min(strftime('%Y-%m-%d', r.date)) as minDate, max(strftime('%Y-%m-%d', r.date)) as maxDate
   from business b join review r using (business_id)
   where city like 'Las Vegas' and b.review_count >= 1000 and b.categories like '%restaurant%'
   group by b.name
   having maxDate - minDate >= 5
   order by b.stars desc;

--List of reviews from users who have reviewed businesses in the base query as well as reviewed other businesses in the same list.

select user.name as userName, b_one.name as firstBusiness, L.stars as firstStar, L.date as firstDate, L.text as firstText, b_two.name as secondBusiness, L.stars as secondStar, L.date as secondDate, L.text as secondText  
from user join reviews_list L on user.user_id = L.user join
   business b_one on b_one.business_id = L.firstBusiness join
   business b_two on b_two.business_id = L.secondBusiness;
--List of users and how many restaurants from the list that user has reviewed

create view review_recommender as
select user.name as userName, b_one.name as firstBusiness, L.stars as firstStar, L.date as firstDate, L.text as firstText, b_two.name as secondBusiness, L.stars as secondStar, L.date as secondDate, L.text as secondText
from user join reviews_list L on user.user_id = L.user join
   business b_one on b_one.business_id = L.firstBusiness join
   business b_two on b_two.business_id = L.secondBusiness;

select userName, count(*) as freq
from review_recommender
group by userName
order by freq desc;
-- Users who have reviewed Viva Las Arepas who have reviewed other businesses in the list


select *
from review A, review B
where A.user_id = B.user_id and
     A.business_id <> B.business_id and
     A.business_id = 'EnCIojgP5KTr1leaysFE3A' and
     B.business_id IN
     (select business_id
     from Restaurants);

create temporary table vivaLasArepasReviewers as
select A.user_id, count(*) as freq
from review A, review B
where A.user_id = B.user_id and
     A.business_id <> B.business_id and
     A.business_id = 'EnCIojgP5KTr1leaysFE3A' and
     B.business_id IN
     (select business_id
     from Restaurants)
group by A.user_id;

select name, vivaLasArepasReviewers.freq
from user join vivaLasArepasReviewers using (user_id);
--User analysis for users who have reviewed Viva Las Arepas and other restaurants on the query list


create temporary table VLA_review as
select A.user_id, A.business_id, A.stars as reviewStar1, B.business_id as otherRestaurant,B.stars as reviewStar2
from review A, review B
where A.user_id = B.user_id and
     A.business_id <> B.business_id and
     A.business_id = 'EnCIojgP5KTr1leaysFE3A' and
     B.business_id IN
     (select business_id
     from Restaurants);

--List of other restaurants reviewed    
create temporary table VLA_restaurants as
select name, business_id, stars as yelpStar
from business
where business_id in (select B.business_id
from review A, review B
where A.user_id = B.user_id and
     A.business_id <> B.business_id and
     A.business_id = 'EnCIojgP5KTr1leaysFE3A' and
     B.business_id IN
     (select business_id
     from Restaurants));
    
select u.name, b.name, b.stars as VLA_yelpstar, R_one.reviewStar1, R_two.name, R_one.reviewStar2, R_two.yelpStar
from VLA_review R_one join VLA_restaurants R_two on R_one.otherRestaurant = R_two.business_id join
   business b on b.business_id = R_one.business_id join
   user u on u.user_id = R_one.user_id; 
 
--These outputs show that users have biases - Sprinkles give less stars than the average yelp rating and Isaiah gives more stars than the average yelp rating.

-	
----------------------------------------------------------------------------------------------------------
  
--Used a new view of a subset of data focusing in only restaurants in Las Vegas

select b.name, b.business_id, b.stars, b.review_count, min(strftime('%Y-%m-%d', r.date)) as minDate, max(strftime('%Y-%m-%d', r.date)) as maxDate
from business b join review r using (business_id)
where city like 'Las Vegas' and b.review_count >= 1000 and b.categories LIKE '%restaurant%'
group by b.name
having maxDate - minDate >= 5
order by b.stars desc;

select *
from question_2_subset;

--What’s the earliest record of a review was given to a business? What’s the latest?
--oldest review data
Select name, MIN(minDate) as oldest_date
from question_2_subset;

--newest review data
Select name, MAX(maxDate) as oldest_date
from question_2_subset;

--When do the reviews happen? Is there a seasonality to it? Example: do more reviews get posted in the summer vs. winter?

WITH ProfileSeasons AS (
SELECT Business_id, review_count,
CASE
WHEN STRFTIME('%m', minDate) IN ('12', '01', '02') THEN 'Winter'
WHEN STRFTIME('%m', minDate) IN ('03', '04', '05') THEN 'Spring'
WHEN STRFTIME('%m', minDate) IN ('06', '07', '08') THEN 'Summer'
WHEN STRFTIME('%m', minDate) IN ('09', '10', '11') THEN 'Fall'
END AS season_start,
CASE
WHEN STRFTIME('%m', maxDate) IN ('12', '01', '02') THEN 'Winter'
WHEN STRFTIME('%m', maxDate) IN ('03', '04', '05') THEN 'Spring'
WHEN STRFTIME('%m', maxDate) IN ('06', '07', '08') THEN 'Summer'
WHEN STRFTIME('%m', maxDate) IN ('09', '10', '11') THEN 'Fall'
END AS season_end
FROM question_2_subset
),
SeasonalProfiles AS (
SELECT business_id, review_count, season_start AS season
FROM ProfileSeasons
UNION ALL
SELECT business_id, review_count, season_end AS season
FROM ProfileSeasons
WHERE season_start != season_end 
)
SELECT season, COUNT(DISTINCT business_id) AS business, SUM(review_count) AS total_review_count
FROM SeasonalProfiles
GROUP BY season
ORDER BY review_count DESC;
