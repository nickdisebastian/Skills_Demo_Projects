USE DATABASE WCD_LAB;

--- Dimension Tables

TRUNCATE TABLE IF EXISTS sakila_anl.customer_dim;
INSERT INTO sakila_anl.customer_dim (
    customer_id,
	first_name,
	last_name,
	email,
	create_date,
	address,
	address2,
	district,
	city_name,
	postal_code,
	phone,
	coutry_name,
	active)
SELECT 
    c.customer_id,
	c.first_name,
	c.last_name,
	c.email,
	c.create_date,
	a.address,
	a.address2,
	a.district,
	ct.city as city_name,
	a.postal_code,
	a.phone,
	cn.country as country_name,
	c.active
FROM sakila.customer c
INNER JOIN sakila.address a USING (address_id)
INNER JOIN sakila.city ct USING (city_id)
INNER JOIN sakila.country cn USING (country_id);

TRUNCATE TABLE IF EXISTS sakila_anl.staff_dim;
INSERT INTO sakila_anl.staff_dim(
    staff_id,
	first_name,
	last_name,
	address,
	address2,
	picture,
	email,
	username,
	district,
	city_name,
	postal_code,
	phone,
	country_name,
	active)
SELECT 
	s.staff_id,
	s.first_name,
	s.last_name,
	a.address,
	a.address2,
	s.picture,
	s.email,
	s.username,
	a.district,
	ct.city AS city_name,
	a.postal_code,
	a.phone,
	cn.country AS country_name,
	s.active
FROM sakila.staff s
LEFT JOIN sakila.address a USING (address_id)
LEFT JOIN sakila.city ct USING (city_id)
LEFT JOIN sakila.country cn USING (country_id);

TRUNCATE TABLE IF EXISTS sakila_anl.store_dim;
INSERT INTO sakila_anl.store_dim (
	store_id,
	manager_firstname,
	manager_lastname,
	address,
	address2,
	district,
	city_name,
	postal_code,
	phone,
	country_name)
SELECT 
	s.store_id,
	st.first_name,
	st.last_name,
	a.address,
	a.address2,
	a.district,
	ct.city AS city_name,
	a.postal_code,
	a.phone,
	cn.country AS country_name
FROM sakila.store s
LEFT JOIN sakila.staff st ON s.manager_staff_id=st.staff_id
LEFT JOIN sakila.address a ON s.address_id=a.address_id
LEFT JOIN sakila.city ct USING (city_id)
LEFT JOIN sakila.country cn USING (country_id);

TRUNCATE TABLE IF EXISTS sakila_anl.film_dim;
INSERT INTO sakila_anl.film_dim (
	film_id,
	title,
	description,
	released_year,
	language,
	original_language,
	rental_duration,
	rental_rate,
	length,
	replace_cost,
	rating,
	special_features,
	category_name)
SELECT 
	f.film_id,
	f.title,
	f.description,
	f.release_year AS released_year,
	l.NAME AS LANGUAGE,
	ll.NAME AS original_language,
	f.rental_duration,
	f.rental_rate,
	f.LENGTH,
	f.replacement_cost AS replace_cost,
	f.rating,
	f.special_features,
    c.NAME AS category_name
FROM sakila.film f
LEFT JOIN sakila.LANGUAGE l USING (language_id)
LEFT JOIN sakila.LANGUAGE ll ON f.original_language_id=ll.language_id
LEFT JOIN sakila.film_category fc USING (film_id)
LEFT JOIN sakila.category c ON fc.category_id=c.category_id;

TRUNCATE TABLE IF EXISTS sakila_anl.calendar_dim;
INSERT INTO sakila_anl.calendar_dim (
    cal_dt,
    day_of_wk_num,
    day_of_wk_desc,
    yr_num,
    wk_num,
    yr_wk_num,
    mnth_num,
    yr_mnth_num)
SELECT
    cal_dt,
    day_of_wk_num,
    day_of_wk_desc,
    yr_num,
    wk_num,
    yr_wk_num,
    mnth_num,
    yr_mnth_num
FROM
    sakila.calendar_dim;
    

--- Fact table

CREATE OR REPLACE TRANSIENT TABLE sakila_anl.trans_base_stg AS  
SELECT
	p.payment_date AS trans_dt,
	p.customer_id,
	p.staff_id,
	i.store_id,
	i.film_id,
	p.amount
FROM sakila.payment p 
JOIN sakila.rental r USING (rental_id, customer_id, staff_id)
JOIN sakila.inventory i ON r.inventory_id = i.inventory_id;

--- generate In Decline column
--- define transactions date range
SET max_dt = (SELECT max(payment_date) FROM sakila.payment);
SET min_dt = (SELECT min(payment_date) FROM sakila.payment);

CREATE OR REPLACE TRANSIENT TABLE sakila_anl.last_4_wk_stg AS 
SELECT 
	c.cal_dt,
	c.yr_wk_num
FROM sakila_anl.calendar_dim c
WHERE c.cal_dt <= $max_dt AND cal_dt >= $min_dt
;

--- build store by week framework
CREATE OR REPLACE TRANSIENT TABLE sakila_anl.last_4_wk_store_stg AS 
SELECT 
	w.yr_wk_num,
	s.store_id,
	w.cal_dt
FROM sakila_anl.last_4_wk_stg w
CROSS JOIN sakila_anl.store_dim s;

--- join sales amount to store by week
CREATE OR REPLACE TRANSIENT TABLE sakila_anl.last_4_wk_trans_stg AS 
SELECT 
	w.store_id,
	w.yr_wk_num,
	nvl(sum(t.amount),0) AS wk_amount
FROM sakila_anl.last_4_wk_store_stg w 
LEFT JOIN sakila_anl.trans_base_stg T  ON T.trans_dt=w.cal_dt AND T.store_id = w.store_id
GROUP BY 1,2
ORDER BY 1,2;

--- Flag declining over 4 weeks
CREATE OR REPLACE TRANSIENT TABLE sakila_anl.last_4_wk_decline AS 
SELECT 
	store_id,
	yr_wk_num,
	in_decline 
FROM 
	(SELECT 
       	*, 
       	CASE WHEN 
       		(wk_amount < last_wk_amount) AND
       		(last_wk_amount < two_wk_ago_amount) AND 
       		(two_wk_ago_amount < three_wk_ago_amount)
       	THEN TRUE ELSE FALSE END AS in_decline
	FROM  
	    (SELECT  
	        *, 
	        LAG(wk_amount) OVER (PARTITION BY store_id ORDER BY yr_wk_num) AS last_wk_amount,
	        LAG(wk_amount,2) OVER (PARTITION BY store_id ORDER BY yr_wk_num) AS two_wk_ago_amount,
	        LAG(wk_amount,3) OVER (PARTITION BY store_id ORDER BY yr_wk_num) AS three_wk_ago_amount
	    FROM sakila_anl.last_4_wk_trans_stg)
	WHERE last_wk_amount IS NOT NULL)
;

--- Join IN_DECLINE column with the sakila_anl.trans_base_stg table
CREATE OR REPLACE TRANSIENT TABLE sakila_anl.transaction_stg AS 
SELECT 
	T.*,
	w.in_decline
FROM sakila_anl.trans_base_stg T
JOIN sakila_anl.last_4_wk_store_stg s ON T.store_id = s.store_id AND T.trans_dt = s.cal_dt
JOIN sakila_anl.last_4_wk_decline w ON T.store_id=w.store_id AND s.yr_wk_num=w.yr_wk_num;


--- replace the current transaction table with new transaction transient table
TRUNCATE TABLE IF EXISTS sakila_anl.transaction;
INSERT INTO sakila_anl.transaction (
		trans_dt,
		customer_id,
		staff_id,
		store_id,
		film_id,
		amount,
		is_decline)
SELECT 
		trans_dt,
		customer_id,
		staff_id,
		store_id,
		film_id,
		amount,
		in_decline
FROM sakila_anl.transaction_stg;

DROP TABLE sakila_anl.trans_base_stg;
DROP TABLE sakila_anl.last_4_wk_stg;
DROP TABLE sakila_anl.last_4_wk_store_stg;
DROP TABLE sakila_anl.last_4_wk_trans_stg;
DROP TABLE sakila_anl.last_4_wk_decline;
DROP TABLE sakila_anl.transaction_stg;

