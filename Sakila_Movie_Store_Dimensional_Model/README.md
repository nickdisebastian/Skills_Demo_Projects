# Sakila Movie Store Dimensional Modeling

## Project Description
This project takes data from an OLTP system for a retail movie rental store, creates a dimensional model, and implements that model in a Snowflake Data Warehouse

## Contents
1. data_load : SQL scripts for creating and populating the raw tables 
2. Data Model.xlsx : dimensional model design of prod analytical tables
3. SQL scripts: DDL and DML SQL files for implementation of data model

## ER Diagram of OLTP DB
![OLTP ER Diagram][def]

[def]: ./images/OLTP_ER_diagram.png

## Running the Project
1. Execute os_db_creation.sql and onetime_calendar_dim.sql within data warehouse
2. Execute DDL.sql
3. Execute DML.sql
4. Validate data