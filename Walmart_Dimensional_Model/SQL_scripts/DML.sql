USE DATABASE WCD_LAB;

--- Dimension Tables
--- calendar dim

TRUNCATE TABLE walmart_anl.calendar_dim;
INSERT INTO walmart_anl.calendar_dim (
    cal_dt,
    cal_type_name,
    day_of_wk_num,
    year_num,
    week_num,
    year_wk_num,
    month_num,
    year_month_num,
    qtr_num,
    yr_qtr_num)
SELECT
	cal_dt AS cal_dt,
	cal_type_desc AS cal_type_name,
	day_of_wk_num AS day_of_wk_num,
	yr_num AS year_num,
	wk_num AS week_num,
	yr_wk_num AS year_wk_num,
	mnth_num AS month_num,
	yr_mnth_num AS year_month_num,
	qtr_num AS qtr_num,
	yr_qtr_num AS yr_qtr_num
FROM walmart.calendar
;

--- store dim
--- Slowly Changing Dimention Type 2
--- insert new records
MERGE INTO walmart_anl.store_dim t1
USING walmart.store t2
ON  t1.store_key=t2.store_key
	AND t1.store_name=t2.store_desc
	AND t1.addr=t2.addr
	AND t1.city=t2.city
	AND t1.cntry_cd=t2.cntry_cd
	AND t1.cntry_nm=t2.cntry_nm
	AND t1.prov_name=t2.prov_state_desc
	AND t1.prov_code=t2.prov_state_cd
	AND t1.market_key=t2.market_key
	AND t1.market_name=t2.market_name
    AND t1.submarket_key=t2.submarket_key
	AND t1.submarket_name=t2.submarket_name
	AND t1.latitude=t2.latitude
	AND t1.longitude=t2.longitude
WHEN NOT MATCHED 
THEN INSERT (
	store_key,
	store_name,
	addr,
	city,
	region,
	cntry_cd,
	cntry_nm,
	postal_zip_cd,
	prov_name,
	prov_code,
	market_key,
	market_name,
	submarket_key,
	submarket_name,
	latitude,
	longitude,
	tlog_active_flg,
	start_dt,
	end_dt)
VALUES (
	t2.store_key,
	t2.store_desc,
	t2.addr,
	t2.city,
	t2.region,
	t2.cntry_cd,
	t2.cntry_nm,
	t2.postal_zip_cd,
	t2.prov_state_desc,
	t2.prov_state_cd,
	t2.market_key,
	t2.market_name,
	t2.submarket_key,
	t2.submarket_name,
	t2.latitude,
	t2.longitude,
	TRUE,
	current_date(),
	NULL
);

--- deactivate updated existing records
MERGE INTO walmart_anl.store_dim t1
USING walmart.store t2
ON t1.store_key=t2.store_key
WHEN MATCHED
    AND (
	t1.store_name!=t2.store_desc
	OR t1.addr!=t2.addr
	OR t1.city!=t2.city
	OR t1.region!=t2.region
	OR t1.cntry_cd!=t2.cntry_cd
	OR t1.cntry_nm!=t2.cntry_nm
	OR t1.postal_zip_cd!=t2.postal_zip_cd
	OR t1.prov_name!=t2.prov_state_desc
	OR t1.prov_code!=t2.prov_state_cd
	OR t1.market_key!=t2.market_key
	OR t1.market_name!=t2.market_name
    OR t1.submarket_key!=t2.submarket_key
	OR t1.submarket_name!=t2.submarket_name
	OR t1.latitude!=t2.latitude
	OR t1.longitude!=t2.longitude
)
THEN UPDATE SET end_dt = current_date(), tlog_active_flg=FALSE;


--- product dim
--- Slowly Changing Dimention Type 2
--- insert new records

MERGE INTO walmart_anl.product_dim t1
USING walmart.product t2
ON  
    t1.prod_key  = t2.prod_key
    AND t1.prod_name  = t2.prod_name
    AND t1.vol  = t2.vol
    AND t1.wgt  = t2.wgt
    AND t1.brand_name  = t2.brand_name
    AND t1.status_code  = t2.status_code
    AND t1.status_code_name  = t2.status_code_name
    AND t1.category_key  = t2.category_key
    AND t1.category_name  = t2.category_name
    AND t1.subcategory_key  = t2.subcategory_key
    AND t1.subcategory_name  = t2.subcategory_name
WHEN NOT MATCHED 
THEN INSERT(
    prod_key,
    prod_name,
    vol,
    wgt,
    brand_name,
    status_code,
    status_code_name,
    category_key,
    category_name,
    subcategory_key,
    subcategory_name,
    tlog_active_flg,
    start_dt,
    end_dt)
VALUES (
    t2.prod_key,
    t2.prod_name,
    t2.vol,
    t2.wgt,
    t2.brand_name,
    t2.status_code,
    t2.status_code_name,
    t2.category_key,
    t2.category_name,
    t2.subcategory_key,
    t2.subcategory_name,
    TRUE,
    CURRENT_DATE(),
    NULL
);

--- deactivate updated existing records
MERGE INTO walmart_anl.product_dim t1
USING walmart.product t2
ON  t1.prod_key  = t2.prod_key
WHEN MATCHED 
AND (
    t1.prod_name  != t2.prod_name
    OR t1.vol  != t2.vol
    OR t1.wgt  != t2.wgt
    OR t1.brand_name  != t2.brand_name
    OR t1.status_code  != t2.status_code
    OR t1.status_code_name  != t2.status_code_name
    OR t1.category_key  != t2.category_key
    OR t1.category_name  != t2.category_name
    OR t1.subcategory_key  != t2.subcategory_key
    OR t1.subcategory_name  != t2.subcategory_name
    )
THEN UPDATE SET end_dt = current_date(), tlog_active_flg=FALSE;

--- Fact Tables
--- Remove max date records from sales_inv_store_dy (fact table)
SET LAST_DATE = (SELECT MAX(cal_dt) FROM walmart_anl.sales_inv_store_dy);
DELETE FROM walmart_anl.sales_inv_store_dy WHERE cal_dt=$LAST_DATE;


--- sales_inv_store_dy fact
--- daily sales staging table 
CREATE OR REPLACE TRANSIENT TABLE walmart_anl.daily_sales_stg AS
SELECT 
    prod_key,
    store_key,
    trans_dt AS cal_dt,
    sum(sales_qty) AS sales_qty,
    avg(sales_price) AS sales_price,
    sum(sales_amt) AS sales_amt,
    avg(discount) AS discount,
    sum(sales_cost) AS sales_cost,
    sum(sales_mgrn) AS sales_mgrn,
    sum(ship_cost) AS ship_cost
FROM walmart.sales
WHERE trans_dt >= nvl($LAST_DATE, '1900-01-01')
GROUP BY 1,2,3;
 
--- daily inventory staging table
CREATE OR REPLACE TRANSIENT TABLE walmart_anl.daily_inventory_stg AS
SELECT  
    cal_dt,
    store_key,
    prod_key,
    inventory_on_hand_qty AS stock_on_hand_qty,
    inventory_on_order_qty AS ordered_stock,
    out_of_stock_flg,
    waste_qty,
    promotion_flg,
    next_delivery_dt
FROM walmart.inventory
WHERE cal_dt >= nvl($LAST_DATE, '1900-01-01');

--- sales_inv_store_dy fact
INSERT INTO   walmart_anl.sales_inv_store_dy(
    cal_dt,
	store_key,
	prod_key,
	sales_qty,
	sales_price,
	sales_amt,
	discount,
	sales_cost,
	sales_mgrn,
	stock_on_hand_qty,
	ordered_stock_qty,
	out_of_stock_flg,
	in_stock_flg,
	low_stock_flg
)
SELECT
    COALESCE(s.cal_dt,i.cal_dt),
	COALESCE(s.store_key,i.store_key),
	COALESCE(s.prod_key,i.prod_key),
	nvl(s.sales_qty,0),
	nvl(s.sales_price,0),
	nvl(s.sales_amt,0),
	nvl(s.discount,0),
	nvl(s.sales_cost,0),
	nvl(s.sales_mgrn,0),
	nvl(i.stock_on_hand_qty,0),
	nvl(i.ordered_stock,0),
	nvl(i.out_of_stock_flg,0),
    case when i.out_of_stock_flg= 1 then FALSE else TRUE end as in_stock_flg,
	case when i.stock_on_hand_qty<s.sales_qty then TRUE else FALSE end as low_stock_flg
FROM walmart_anl.daily_sales_stg s
FULL OUTER JOIN walmart_anl.daily_inventory_stg i
USING(cal_dt, prod_key, store_key);

--- sales_inv_store_wk fact
TRUNCATE TABLE IF EXISTS walmart_anl.sales_inv_store_wk;
INSERT INTO walmart_anl.sales_inv_store_wk (
    yr_num,
    wk_num,
    store_key,
    prod_key,
    wk_sales_qty,
    avg_sales_price,
    wk_sales_amt,
    wk_discount,
    wk_sales_cost,
    wk_sales_mgrn,
    eop_stock_on_hand_qty,
    eop_ordered_stock_qty,
    out_of_stock_times,
    in_stock_times,
    low_stock_times)
SELECT
    c.year_num AS yr_num,
    c.week_num AS wk_num,
    s.store_key,
    s.prod_key,
    sum(s.sales_qty) AS wk_sales_qty,
    avg(s.sales_price) AS avg_sales_price,
    sum(s.sales_amt) AS wk_sales_amt,
    avg(s.discount) AS wk_discount,
    sum(s.sales_cost) AS wk_sales_cost,
    sum(s.sales_mgrn) AS wk_sales_mgrn,
    sum(case when c.day_of_wk_num = 6 THEN stock_on_hand_qty else 0 end) AS eop_stock_on_hand_qty,
    sum(case when c.day_of_wk_num=6 then s.ordered_stock_qty else 0 end) as eop_ordered_stock_qty,
	sum(s.out_of_stock_flg) as out_of_stock_times,
	sum(case when s.in_stock_flg=TRUE then 1 else 0 end) as in_stock_times,
	sum(case when s.low_stock_flg=TRUE then 1 else 0 end) as low_stock_times
FROM walmart_anl.sales_inv_store_dy s
JOIN walmart_anl.calendar_dim c USING (cal_dt)
GROUP BY 1,2,3,4;