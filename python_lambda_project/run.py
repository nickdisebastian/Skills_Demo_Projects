#!/usr/bin python3

import sqlalchemy as db
import pandas as pd
import subprocess
import toml
import os
from dotenv import load_dotenv

#Connect to RDS MySQL
def mysql_connect(host, user, password, port,schema):
    engine = db.create_engine(f'mysql+mysqlconnector://{user}:{password}@{host}:{port}/{schema}')
    return engine

if __name__=="__main__": 

    #Load DB variables from config file
    app_config = toml.load('config.toml')
    host=app_config['db']['host']
    port=app_config['db']['port']
    schema=app_config['db']['schema']

    #Load S3 variables from config file
    bucket=app_config['s3']['bucket']
    folder=app_config['s3']['folder']

    #Load DB credentials from .env file
    load_dotenv()
    user=os.getenv('user')
    password=os.getenv('password')

    #SQL query to get top customers
    sql="""
    select customerID, sum(sales) sum_sales
    from orders
    group by 1
    order by 2 desc
    limit 10;
    """
    engine = mysql_connect(host, user, password, port, schema)

    df = pd.read_sql(sql, con = engine)
    df[["customerID"]].head()
    df[["customerID"]].to_json('cus_id.json')

    #post JSON to S3 bucket
    subprocess.call(['aws','s3','cp','cus_id.json', f's3://{bucket}/{folder}/cus_id.json'])