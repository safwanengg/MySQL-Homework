#1a. Display the first and last names of all actors from the table `actor`.
select first_name, last_name from actor;
#1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT CONCAT(first_name,' ', last_name) AS "Actor Name"
  FROM actor
#2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
#What is one query would you use to obtain this information?
select actor_id,first_name, last_name from actor where first_name LIKE "JOE";
#2b. Find all actors whose last name contain the letters `GEN`:
select first_name,last_name from actor where last_name LIKE '%GEN%';
#2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
select actor_id,first_name,last_name from actor where last_name like '%LI%' ORDER BY last_name,first_name;
#2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id,country from country where country IN ('Afghanistan','Bangladesh','China');
#3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column 
#in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between
# it and `VARCHAR` are significant)
alter table actor;
ADD COLUMN description BLOB AFTER last_name;
#3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER table actor
DROP COLUMN description;
#4a. List the last names of actors, as well as how many actors have that last name.
select last_name,count(*) from actor group by last_name
#4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least
# two actors
create table actor1
as
(select last_name,count(*) as count from actor group by last_name); 
select * from actor1 where count >= 2;
#4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
UPDATE actor 
SET 
    first_name = 'HARPO'
WHERE
    last_name = 'WILLIAMS' and first_name = 'GROUCHO';
#4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! 
#In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor 
SET 
    first_name = 'GROUCHO'
WHERE
    last_name = 'WILLIAMS' and first_name = 'HARPO';
#5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
SHOW CREATE TABLE address;
#6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
select * from sakila.staff s, sakila.address a
where s.address_id = a.address_id;
SELECT s.first_name,s.last_name,a.address
FROM staff s 
INNER JOIN address a ON
s.address_id = a.address_id;
#6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
use sakila;
create table staffpaymentaugust
as
(select * from payment where payment_date > '2005-08-01' and payment_date < '2005-09-01');
select * from sakila.staff s, sakila.staffpaymentaugust au
where s.staff_id = au.staff_id;
SELECT s.first_name,s.last_name,au.amount
FROM staff s 
INNER JOIN staffpaymentaugust au ON
s.staff_id = au.staff_id;
#6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
select * from film_actor;
select * from film;
create table filmy
as
(SELECT film.film_id,film.title,film_actor.actor_id
FROM film
INNER JOIN film_actor ON
film.film_id = film_actor.film_id);
select film_id, title, count(*) as "Number of Actors" from filmy group by film_id;
#6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
create table filmer
as
(SELECT film.film_id,film.title,inventory.inventory_id
FROM film
INNER JOIN inventory ON
film.film_id = inventory.film_id);
select film_id,title,count(*) as "Number of Copies" from filmer where title = 'Hunchback Impossible';
#6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers 
#alphabetically by last name:
create table cus
as
(SELECT customer.customer_id,customer.first_name,customer.last_name,payment.amount
FROM customer
INNER JOIN payment ON
customer.customer_id = payment.customer_id);
select customer_id, first_name, last_name, SUM(amount) as Total from cus group by last_name;
#7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with 
#the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` 
#and `Q` whose language is English.
select @k:= language_id from language where name = 'English' ;
select title,language_id from film where title LIKE 'K%' or title like 'Q%' and language_id = @k;
#7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
create table alonetrip
as
(select * from filmy where title = 'Alone Trip');
select alonetrip.actor_id,actor.first_name,actor.last_name,alonetrip.title
from actor
INNER JOIN alonetrip ON
actor.actor_id = alonetrip.actor_id;
#7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian 
#customers. Use joins to retrieve this information.
create table canadacustomer
as
(select * from customer_list where country = 'Canada');
select * from canadacustomer;
select customer.customer_id,canadacustomer.name,customer.email
from customer
INNER JOIN canadacustomer ON
customer.customer_id = canadacustomer.ID;
#7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies 
#categorized as _family_ films.
# I am assuming all family films are rated as G.
select film_id,title,description,rating from film where rating = 'G';
#7e. Display the most frequently rented movies in descending order.
create table inv
as
(select inventory_id,film_id,count(*) as "Number_of_times_rented" from inventory group by film_id);
select rental.inventory_id,inv.film_id,film.title,inv.Number_of_times_rented
from rental
INNER JOIN inv ON
rental.inventory_id = inv.inventory_id
INNER JOIN film ON
inv.film_id = film.film_id
group by title
order by Number_of_times_rented desc;
#7f. Write a query to display how much business, in dollars, each store brought in.
create table customeramount
as
(select customer_id,sum(amount) as Total from payment group by customer_id);
select * from customer;
create table storedollars
as
(select customeramount.customer_id,customeramount.Total,customer.store_id
from customeramount
INNER JOIN customer ON
customeramount.customer_id = customer.customer_id);
select store_id, SUM(Total) as business_in_dollars from storedollars group by store_id;
#7g. Write a query to display for each store its store ID, city, and country.
select store.store_id,city.city,country.country
from store
INNER JOIN address on
store.address_id = address.address_id
INNER JOIN city on
address.city_id = city.city_id
INNER JOIN country on 
city.country_id = country.country_id;
#7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: 
#category, film_category, inventory, payment, and rental.)
select * from category;
select * from film_category;
select * from inventory;
select * from payment;
select * from rental;
create table fivegenres 
as
(select category.category_id,category.name,payment.rental_id,payment.amount
from category
INNER JOIN film_category on
category.category_id = film_category.category_id
INNER JOIN inventory on
film_category.film_id = inventory.film_id
INNER JOIN rental on
inventory.inventory_id = rental.inventory_id
INNER JOIN payment on
rental.rental_id = payment.rental_id);
select category_id,name,SUM(amount) as gross_revenue from fivegenres group by name order by gross_revenue desc LIMIT 5 ;
#8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
#Use the solution from the problem above to create a view.
CREATE VIEW top_five_genres_View 
AS
(select category_id,name,SUM(amount) as gross_revenue from fivegenres group by name order by gross_revenue desc LIMIT 5) ;
#8b. How would you display the view that you created in 8a?
select * from top_five_genres_View;
#8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_five_genres_View;





