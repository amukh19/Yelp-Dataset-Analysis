/*How many businesses are included in the dataset? 
(23,507) → counts unique names (name is counted once) 
*/

select count(distinct name)
from business; 

--Where are they located / How many reviews per business (top 10)
select name as business_name, city, state, review_count
from business
group by name, city, state, review_count
order by review_count DESC
limit 10;

--How many total businesses are located in Las Vegas? 
(5318)
select count(distinct name) as Business_located_in_Las_Vegas
from business
where city = 'Las Vegas';

--What are the top 3 businesses with highest review count 
--(each business must be located in different cities)

select name as business_name, city, state, review_count
from business
where city !=  'Las Vegas'
group by name, city, state, review_count
order by review_count DESC;

select name as business_name, city, state, review_count
from business
where city != 'Las Vegas' and city != 'Phoenix'
group by name, city, state, review_count
order by review_count DESC;

-Identify star rating for Mon Ami Gabi, Phoenix Harbor International Airport, Studio B Buffet (top 3 businesses w/ highest review count)

select name, stars
from business
where name in ('Mon Ami Gabi','Phoenix Sky Harbor International Airport','Studio B Buffet')

--Identify unique business names with category in restaurant (13948)
select distinct(name) as business, categories
from business
where categories LIKE '%Restaurant%';


--Identify top 3 businesses with the highest star rating in Las Vegas, restaurant category, has over 1000 review count w/ the user table joined (Q2)

select b.name,
b.business_id,
b.stars,
b.review_count,
min(strftime('%Y-%m-%d', r.date)) as minDate,
max(strftime('%Y-%m-%d', r.date)) as maxDate,
COUNT(r.review_id) AS reviews,
u.name as user_name
from business b join review r using (business_id)
join user u on r.user_id = u.user_id
where city like 'Las Vegas' and b.review_count >= 1000 and categories LIKE '%restaurant%'
group by b.name
having maxDate - minDate >= 5
order by b.stars desc
limit 3;

--(Part 2: Above code simplified) - Snippet taken here for presentation chart Q2

select b.name,
b.stars,
min(strftime('%Y-%m-%d', r.date)) as minDate,
max(strftime('%Y-%m-%d', r.date)) as maxDate,
COUNT(r.review_id) AS reviews
from business b join review r using (business_id)
where city like 'Las Vegas' and b.review_count >= 1000 and categories LIKE '%restaurant%'
group by b.name
having maxDate - minDate >= 5
order by b.stars desc
limit 3;

/*Restaurants based on code above (3 restaurants with 4.5 star rating)(Q2)

Viva Las Arepas // 11 reviews
Raku // 6 reviews
Oyster Bar // 17 reviews
*/

--Identify all user names for ‘Viva Las Arepas’ (users who rated the business)(Q2)

select b.name as business_name, u.name as user_name, u.average_stars as average_rating
from business b join review r using (business_id)
join user u on r.user_id = u.user_id
where
b.name = 'Viva Las Arepas' AND
b.city like 'Las Vegas' AND
b.review_count >=1000 AND
b.categories like '%restaurant%'
order by u.name;

--Identify all user names for ‘Raku’ (users who rated the business)(Q2 on presentation)

select b.name as business_name, u.name as user_name, u.average_stars as average_rating
from business b join review r using (business_id)
join user u on r.user_id = u.user_id
where
b.name = 'Raku' AND
b.city like 'Las Vegas' AND
b.review_count >=1000 AND
b.categories like '%restaurant%'
order by u.name;


--Identify all user names for ‘Oyster Bar’ (users who rated the business)(Q2)

select b.name as business_name, u.name as user_name, u.average_stars as average_rating
from business b join review r using (business_id)
join user u on r.user_id = u.user_id
where
b.name = 'Oyster Bar’' AND
b.city like 'Las Vegas' AND
b.review_count >=1000 AND
b.categories like '%restaurant%'
order by u.name;
