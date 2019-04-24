-- mySQL homework: analyzing sakila database and extracting information
-- from different tables
-- Using the sakila database
USE sakila;
-- 1.a writing the firt name and the last name from the table actor
SELECT actor.first_name,
actor.last_name FROM actor;

-- 1.b Modifying the table actor adding a column named 'Actor Name' as actor_name
-- no spaces between names in mysql, the column actor_name is a character column.
-- Insert the first and last name in column actor_name, printing actor_name
ALTER TABLE actor
ADD COLUMN actor_name VARCHAR(200) AFTER last_name;
UPDATE actor SET actor_name = CONCAT(first_name, ' ',last_name);
SELECT actor_name FROM actor;

-- 2.a Finding the information of Joe
SELECT*FROM actor
WHERE first_name = 'Joe';

-- 2.b Find all last names that contains the letters "GEN"
SELECT*FROM actor
WHERE last_name LIKE '%GEN%';

-- 2.c Find all actors whose last name contains the letters "Li"
SELECT last_name, first_name FROM actor
WHERE last_name LIKE '%Li%';

-- 2.d Using IN display country id, and country columns for
SELECT country_id, country FROM country
WHERE country IN ('Afghanistan','Bangladesh','China');

-- 3.a Create 'description' column in table actor with data type "BLOB"
ALTER TABLE actor
ADD COLUMN description 	VARBINARY(8000) AFTER actor_name;

-- Just to look if the description column was created
SELECT *FROM actor
WHERE description;

-- 3.b Make up your  mind then delete description
ALTER TABLE actor
DROP COLUMN description;

-- Just to check is description gone
SELECT*FROM actor;

-- 4.a List and count last names
SELECT DISTINCT(last_name) as LastName, count(last_name) AS count 
FROM actor 
GROUP BY last_name 
HAVING count > 1;

-- 4.b List and count last names for those actors with the same name
SELECT DISTINCT(actor_name) as ActorName, count(actor_name) AS samename
FROM actor 
GROUP BY actor_name
HAVING samename > 1;

-- 4.c change the name in a column: just one entry replace Groucho for Harpo name
SELECT last_name, first_name
FROM actor
WHERE last_name = 'WILLIAMS' AND first_name = 'GROUCHO';
UPDATE actor
SET first_name = 'HARPO'
WHERE last_name = 'WILLIAMS' AND first_name ='GROUCHO';

SELECT last_name, first_name FROM actor
WHERE  last_name = 'WILLIAMS';

-- 4.d Mistake! What! Oh My.. ok set back to Groucho ;)
SELECT last_name, first_name FROM actor
WHERE  last_name = 'WILLIAMS' AND first_name = 'HARPO';
UPDATE actor
SET first_name = 'GROUCHO'
WHERE  last_name = 'WILLIAMS' AND first_name = 'HARPO';

SELECT last_name, first_name FROM actor
WHERE  last_name = 'WILLIAMS';

-- 5.a Re-create a table 'recreate' with the scheme
SHOW CREATE TABLE address;
DESCRIBE address;

-- 6.a Use 'JOIN' to display first, last name and address using 'staff' and 'address'
SELECT * FROM address;
SELECT * FROM staff;

SELECT s.first_name, s.last_name, a.address
FROM staff AS s
join address AS a
on s.address_id=a.address_id;

-- Inspecting the staff and payment
SELECT * FROM staff;

SELECT p.payment_date, p.staff_id, p.amount, s.first_name, s.last_name, s.staff_id
FROM payment AS p
JOIN staff AS s
ON p.staff_id = s.staff_id
WHERE DATE (p.payment_date) BETWEEN '2005-08-01' AND '2005-08-31 23:59:59'
	ORDER BY p.staff_id;
    
    

-- 6.b Expenses by each staff member during August 2005
SELECT s.first_name, s.last_name, DATE (p.payment_date) BETWEEN '2005-08-01' AND '2005-08-31 23:59:59' AS august, SUM(p.amount) AS expenses
FROM staff AS s
JOIN payment AS p 
	ON s.staff_id = p.staff_id
GROUP BY p.staff_id;

-- inspecting tables film and film_actor
SELECT * FROM film;
SELECT * FROM film_actor;

-- List each film and the number of actors who are listed for that film
SELECT f.title, COUNT(a.actor_id) AS 'number of actors'
FROM film AS F
INNER JOIN film_actor AS a
ON f.film_id = a.film_id;

-- Inspecting Inventory system
SELECT*FROM inventory;

-- 6.d How many copies of the film 'Hunchback impossible' exist in inventory?
SELECT COUNT(i.store_id) AS 'Number of Copies', f.title
FROM inventory AS i
JOIN film AS f
ON i.film_id = f.film_id
WHERE title = 'Hunchback impossible';

-- Exploring payment and customer tables
SELECT*FROM payment;
SELECT*FROM customer;

-- 6.e Total paid by each customer (alphabetical by last name)
SELECT c.last_name, c.first_name, SUM(p.amount) AS 'Total Amaount Paid'
FROM customer AS c
JOIN payment AS p
	ON (c.customer_id = p.customer_id)
GROUP BY c.last_name;

-- 7a queries for movie titles starting with K and Q who language is English
SELECT title, language_id AS English
FROM film 
WHERE language_id='1';

SELECT title
FROM film
where title LIKE 'K%'
UNION
SELECT title
FROM film
WHERE title LIKE 'Q%'
;

-- 7b  Use subqueries to display ALL actors who appear in 'Alone Trip'
SELECT last_name, first_name
FROM actor
WHERE actor_id IN 
(SELECT actor_id
FROM film_actor
WHERE film_id IN 
(SELECT film_id
FROM film
WHERE title = 'Alone Trip'
)
);

-- 7.c Email marketing campaign to Canada!
SELECT c.country_id='Canada',cu.last_name, cu.first_name, cu.email
FROM country AS c
JOIN city AS cy
ON (c.country_id = cy.country_id) 
JOIN address AS a
ON (cy.city_id = a.city_id)
JOIN customer AS cu
ON ( a.address_id = cu.address_id);

-- 7.d All family movies for a promotion, find all family films.
SELECT ca.name AS category, f.rating, f.title
FROM film AS f
JOIN film_category AS fca
ON (f.film_id = fca.film_id)
JOIN category AS ca
ON (fca.category_id = ca.category_id)
WHERE ca.name = 'Family';

-- 7.e Display the most frequently rented movies in descending order
SELECT  f.title, COUNT(title) AS '# of frequently rented'
FROM rental AS r
JOIN inventory AS i
ON (r.inventory_id = i.inventory_id)
JOIN film AS f
ON (i.film_id = f.film_id)
GROUP BY title
ORDER BY 2 DESC;

-- 7.f How much business each store brought in 
SELECT i.store_id, SUM(p.amount) AS sales
FROM payment AS p
JOIN rental AS r
ON (p.rental_id = r.rental_id)
JOIN inventory AS i
ON (r.inventory_id = i.inventory_id)
GROUP BY store_id;

-- 7.g For each store display store ID, City and Country

SELECT  c.store_id AS 'Store ID', ci.city AS 'City', co.country AS 'Country'
FROM customer AS c
JOIN address AS ad
ON (c.address_id = ad.address_id)
JOIN city AS ci
ON (ad.city_id = ci.city_id)
JOIN country AS co
ON (ci.country_id = co.country_id);

-- 7.h Gross Revenue = Total Sales - Total Expenses

SELECT ca.name, SUM(p.amount) AS 'Gross Sales'
FROM payment AS p
JOIN rental AS r
ON (p.rental_id = r.rental_id)
JOIN inventory AS i
ON (r.inventory_id = i.inventory_id)
JOIN film AS f
ON (f.film_id = i.film_id)
JOIN film_category AS fca
ON (f.film_id = fca.film_id)
JOIN category AS ca
ON (fca.category_id = ca.category_id)
GROUP BY ca.name
ORDER BY 2 DESC LIMIT 5;

-- 8.a Create a view to display the top five genres with gross revenue = gross sales

CREATE VIEW gross_sales AS
SELECT ca.name, f.title, SUM(p.amount) AS ' Gross Sales'
FROM payment AS p
JOIN rental AS r
ON (p.rental_id = r.rental_id)
JOIN inventory AS i
ON (r.inventory_id = i.inventory_id)
JOIN film AS f
ON (f.film_id = i.film_id)
JOIN film_category AS fca
ON (f.film_id = fca.film_id)
JOIN category AS ca
ON (fca.category_id = ca.category_id)
GROUP BY title;

SELECT*
FROM gross_sales
ORDER BY name;

SELECT*
FROM gross_sales
ORDER BY 3 DESC LIMIT 5;

-- 8.b How would you display the view that you created in 8.a?

SELECT*FROM gross_sales;

-- 8.c Write a query to delete 8.a "The View"

DROP VIEW gross_sales;