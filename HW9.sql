use sakila;
SELECT * FROM actor;

-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT upper(concat(first_name , ' ', last_name)) as full_name FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id,first_name, last_name 
FROM actor
WHERE first_name LIKE 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT actor_id,first_name, last_name 
FROM actor
WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT actor_id,first_name, last_name 
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id,country 
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE actor
ADD COLUMN description blob AFTER last_name;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor
DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, count(last_name) as Counter_Same_last_name
FROM actor
group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, count(last_name) as Counter_Same_last_name
FROM actor
group by last_name
having count(last_name) > 1;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor
SET first_name = 'HARPO'
where last_name = 'WILLIAMS' and first_name = 'GROUCHO';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor
SET first_name = 'GROUCHO'
where last_name = 'WILLIAMS' and first_name = 'HARPO';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
CREATE TABLE `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT s.first_name, s.last_name, a.address, a.district, a.postal_code
FROM sakila.staff s, sakila.address a
where s.address_id = a.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT s.first_name, s.last_name, 
	(Select SUM(p.amount) from sakila.payment p where p.staff_id = s.staff_id 
    AND YEAR(p.payment_date) = 2005
    ) AS Total_Amount
FROM sakila.staff s;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT f.title, count(a.actor_id) as Total_actor
FROM sakila.film f, sakila.film_actor a
WHERE f.film_id = a.film_id
GROUP BY f.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT f.title, count(i.inventory_id) as total_copies
	FROM inventory i, film f
	where i.film_id = f.film_id
    and f.title =  'Hunchback Impossible'
	group by f.title;

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT c.first_name, c.last_name,sum(p.amount) as 'Total Amount Paid'
FROM sakila.customer c, sakila.payment p
where c.customer_id = p.customer_id
group by p.customer_id
order by c.last_name
;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT f.title, f.language_id,(Select l.name from sakila.language l where f.language_id = l.language_id and l.name='English') as 'Language'
FROM sakila.film f
WHERE f.title like ('K%') or f.title like ('Q%');

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
Select a.first_name, a.last_name
FROM sakila.actor a
WHERE a.actor_id IN
	(Select actor_id
	FROM sakila.film_actor fa
	WHERE fa.film_id IN 
		(SELECT f.film_id 
		FROM sakila.film f
		WHERE f.title = 'Alone Trip'
		)
	);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT cust.first_name, cust.last_name,cust.email 
FROM sakila.country ctry,sakila.city c,sakila.address a ,sakila.customer cust
WHERE ctry.country = 'Canada'
AND ctry.country_id = c.country_id
AND c.city_id = a.city_id
AND cust.address_id = a.address_id
;

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT f.title, c.name as Category 
FROM sakila.category c, sakila.film_category fc, sakila.film f
WHERE c.name = 'Family'
AND c.category_id = fc.category_id
AND f.film_id = fc.film_id
;

-- 7e. Display the most frequently rented movies in descending order.
SELECT f.title, count( f.title) as 'Rented count'
FROM sakila.rental r, sakila.inventory i, sakila.film f
WHERE r.inventory_id = i.inventory_id
AND f.film_id = i.film_id
group by  f.title
order by count( f.title) desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id, sum(p.amount) AS Amount
FROM sakila.payment p, sakila.customer c, sakila.store s
Where p.customer_id = c.customer_id
AND c.store_id = s.store_id
group by s.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, c.city, co.country
FROM sakila.store s, sakila.address a, sakila.city c, sakila.country co
WHERE s.address_id = a.address_id
AND c.city_id = a.city_id
and co.country_id = c.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT c.name as Genre, sum(p.amount) as Amount
FROM sakila.payment p, sakila.rental r, sakila.inventory i, sakila.film f, sakila.film_category fc, sakila.category c
WHERE p.rental_id = r.rental_id
AND r.inventory_id = i.inventory_id
AND i.film_id = f.film_id
AND f.film_id = fc.film_id
AND fc.category_id = c.category_id
group by c.name
order by sum(p.amount) desc
limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW Top_5_by_Genre_v AS (
SELECT c.name as Genre, sum(p.amount) as Amount
FROM sakila.payment p, sakila.rental r, sakila.inventory i, sakila.film f, sakila.film_category fc, sakila.category c
WHERE p.rental_id = r.rental_id
AND r.inventory_id = i.inventory_id
AND i.film_id = f.film_id
AND f.film_id = fc.film_id
AND fc.category_id = c.category_id
group by c.name
order by sum(p.amount) desc
limit 5);

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM sakila.top_5_by_genre_v;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW sakila.top_5_by_genre_v;