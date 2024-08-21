import requests
import pandas as pd
import json 
import sqlalchemy as db
from sqlalchemy import create_engine, text
from dotenv import load_dotenv
from datetime import date
import os
import toml 
import subprocess
import boto3

# define functions
# create DB engine structure
def mysql_connect(host, user, password, port, schema):
    engine = db.create_engine(f'mysql+mysqlconnector://{user}:{password}@{host}:3306/superstore')
    return engine

# read customer_id_file and return a string list of customer_id
def get_customer_id(cusid_file):
    li=[]
    with open(cusid_file,'rb') as f:
        data = json.load(f)
        for value in data["customerID"].values():
            li.append(str(value))
        
    id_string = "("+ ",".join(li)+")"
    return id_string

# get customer data from DB
def get_customer_data(engine, sql):
    with engine.connect() as connection:
        mysql_result = connection.execute(text(sql))
    records=[]
    for row in mysql_result:
        doc={"id":row[0], "name":row[1], "date":date.today().strftime('%Y-%m-%d')}
        records.append(doc)
    data=json.dumps(records)
    return data


# define lambda function
def lambda_handler(event, context):
    print("Received event: " + json.dumps(event, indent=2))
    
    app_config = toml.load('config.toml')


    # load API URL from config file
    api_url = app_config['api']['api_url']
    

    # load DB connection variables from config file
    host=app_config['db']['host']
    port=app_config['db']['port']
    schema=app_config['db']['schema']


    # load DB credentials & access keys from .env file
    load_dotenv()
    user=os.getenv('user')
    password=os.getenv('password')
    access_key=os.getenv('access_key')
    secret_key=os.getenv('secret_key')

    # read customer_id_file from s3 to local
    # create client to connect to s3 bucket
    s3_client = boto3.client('s3', aws_access_key_id=access_key, aws_secret_access_key=secret_key)
    

    # define variables for download
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key'].split("/")[1]
    filepath = "/tmp/" +  key
    download_key = 'input/'+key
    

    # read customer_id_file from s3 to local
    s3_client.download_file(Bucket=bucket, Key= download_key, Filename=filepath)


    # build connection to the MySQL database
    engine = mysql_connect(host, user, password, port, schema)
    
    # get the customer id and insert it into the sql statement
    ids = get_customer_id(filepath)

    sql=f"""select customerID, CustomerName
            from customers
            where customerID in {ids} ;
         """
    
    # get the customer data from database

    data = get_customer_data(engine, sql)


    # post data to api
    request = requests.post(api_url, data=data)
    
    
    print(request.status_code)

