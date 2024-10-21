# Sakila Movie Store Dimensional Modeling

## Project Description
This project takes data from an OLTP system for Walmart (retail data), creates a dimensional model, and implements that model in a Snowflake Data Warehouse

## Contents
1. build_os_db.sql : DDL for raw tables
2. walmart raw data : dimensional model design of prod analytical tables
3. SQL scripts: DDL and DML SQL files for implementation of data model

## Running the project
1. Execute build_os_db.sql within data warehouse
2. Load walmart raw data csvs into corresponding raw tables
2. Execute DDL.sql to dimensional model structure
3. Execute DML.sql to populate alanytics tables
4. Validate data