--How many users (elite vs non-elite)  joined per year? 
-- number of elite users joined per year
create temporary table elite1 as
select strftime('%Y', yelping_since) as userSince, count(*) as numEliteUsers
from user
where elite is not null
group by userSince
order by userSince asc;

--number of regular users joined per year
create temporary table regular1 as
select strftime('%Y', yelping_since) as userSince, count(*) as numRegularUsers
from user
where elite is null
group by userSince
order by userSince asc;
  
--combine together in one table
select elite1.userSince, elite1.numEliteUsers, regular1.numRegularUsers
from elite1 join regular1 using (userSince);

--What is the average review count, as well as Useful, Funny, Cool and Fans ratings for users (elite vs non-elite)? 

select round(avg(review_count),2) avgReviewCount, round(avg(useful),2) as avgUseful, round(avg(funny),2) as avgFunny, round(avg(cool),2) as avgCool, round(avg(fans),2) as avgFans
from user
where elite is not null
UNION ALL
select round(avg(review_count),2) avgReviewCount, round(avg(useful),2) as avgUseful, round(avg(funny),2) as avgFunny, round(avg(cool),2) as avgCool, round(avg(fans),2) as avgFans
from user
where elite is null;

--What is the average review count, as well as Useful, Funny, Cool and Fans ratings for users grouped by the average rating they give? 
select min(average_stars) as minStar, max(average_stars) as maxStar, avg(useful) as avgUseful, avg(funny) as avgFunny, avg(cool) as avgCool, avg(fans) as avgFans
from user
where average_stars >= 1 and average_stars < 2
UNION ALL
select min(average_stars) as minStar, max(average_stars) as maxStar, avg(useful) as avgUseful, avg(funny) as avgFunny, avg(cool) as avgCool, avg(fans) as avgFans
from user
where average_stars >= 2 and average_stars < 3
UNION ALL
select min(average_stars) as minStar, max(average_stars) as maxStar, avg(useful) as avgUseful, avg(funny) as avgFunny, avg(cool) as avgCool, avg(fans) as avgFans
from user
where average_stars >= 3 and average_stars < 4
UNION ALL
select min(average_stars) as minStar, max(average_stars) as maxStar, avg(useful) as avgUseful, avg(funny) as avgFunny, avg(cool) as avgCool, avg(fans) as avgFans
from user
where average_stars >= 4 and average_stars <= 5;

--How many reviews were given per year, and categorize them into each rating.
--by year and shows average rating
create temporary table star2 as
select strftime('%Y',date) as year, count(*) as totalReviews, avg(stars) as avgRating
from review
group by year;

create temporary table star1 as
   select strftime('%Y',date) as year,
       case
       when stars == 5 then 'FiveStars'
       when stars == 4 then 'FourStars'
       when stars == 3 then 'ThreeStars'
       when stars == 2 then 'TwoStars'
       when stars == 1 then 'OneStar'
       when stars == 0 then 'ZeroStars'
       end as Rating, count(*) as numReviews
   from review
   group by year, Rating;

-- shows by year how many of each rated businesses there are and the average rating for that year
select *
from star1 join star2 using (year)
order by year;
 
