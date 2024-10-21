USE DATABASE WCD_LAB;

CREATE SCHEMA IF NOT EXISTS walmart_anl;

--- Dimensions Tables

CREATE OR REPLACE TABLE walmart_anl.calendar_dim 
(
    cal_dt date NOT NULL,
    cal_type_name   varchar(30),
    day_of_wk_num   int,
    year_num        int,
    week_num        int,
    year_wk_num     int,
    month_num       int,
    year_month_num  int,
    qtr_num         int,
    yr_qtr_num      int,
    update_time     timestamp default CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE walmart_anl.store_dim
(
	store_key	INTEGER,
	store_name	varchar(150),
	status_code	varchar(10),
	status_cd_name	varchar(100),
	open_dt	date,
	close_dt	date,
	addr	varchar(500),
	city	varchar(50),
	region varchar(100),
	cntry_cd	varchar(30),
	cntry_nm	varchar(150),
	postal_zip_cd	varchar(10),
	prov_name	varchar(30),
	prov_code	varchar(30),
	market_key	integer,
	market_name	varchar(150),
	submarket_key	integer,
	submarket_name	varchar(150),
	latitude	NUMERIC(19, 6),
	longitude	NUMERIC(19, 6),
	tlog_active_flg boolean,
	start_dt date,
	end_dt date,
	update_time	timestamp default CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE walmart_anl.product_dim 
(
    prod_key    int PRIMARY KEY,
    prod_name   varchar(30),
    vol         number(38,2),
    wgt         number(38,2),
    brand_name	varchar(30),
    status_code	int,
    status_code_name varchar(30),
    category_key int,
    category_name varchar(30),
    subcategory_key	int,
    subcategory_name varchar(30),
    tlog_active_flg	boolean,
    start_dt  date,
    end_dt	date,
    update_time	timestamp default CURRENT_TIMESTAMP()
);

--- Fact Tables

CREATE OR REPLACE TABLE walmart_anl.sales_inv_store_dy 
(
    cal_dt	date,
    store_key	int,
    prod_key	int,
    sales_qty	number(38,2),
    sales_price	number(38,2),
    sales_amt	number(38,2),
    discount	number(38,2),
    sales_cost	number(38,2),
    sales_mgrn	number(38,2),
    stock_on_hand_qty	number(38,2),
    ordered_stock_qty	number(38,2),
    out_of_stock_flg	number(38,2),
    in_stock_flg    boolean,
    low_stock_flg	boolean,
    update_time	timestamp default CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE walmart_anl.sales_inv_store_wk 
(
    yr_num	int,
    wk_num	int,
    store_key	int,
    prod_key	int,
    wk_sales_qty	number(38,2),
    avg_sales_price	number(38,2),
    wk_sales_amt	number(38,2),
    wk_discount	number(38,2),
    wk_sales_cost	number(38,2),
    wk_sales_mgrn	number(38,2),
    eop_stock_on_hand_qty	number(38,2),
    eop_ordered_stock_qty	number(38,2),
    out_of_stock_times	int,
    in_stock_times	int,
    low_stock_times	int,
    update_time	timestamp default CURRENT_TIMESTAMP()
);