# Python Cloud Lambda Mini-Project

## Project Description

This project reads customerID data from an AWS MySQL RDS, converts the results to a JSON file and stores it an S3 bucket. The file post to the S3 bucket triggers a lambda function which queries the RDS DB based on the data in the customerID JSON. The resulting customerDetails JSON is then posted to an API.

![Project Structure][def]

[def]: ./images/project_structure.png

## Running the Project
# Project setup
1. Create S3 bucket
2. Launch and SSH into EC2 instance
3. Create IAM AWS Service role with full s3 access and attach role to EC2 instance
4. Create MySQL RDS
    - Connect to DB through SQL client (MySQL Workbench) and load data (provided by boot camp)

# Python script
5. Create .env file with DB credentials
6. Within config.toml, update the API URL, AWS S3 bucket, and DB details
7. Set permissions for init.sh to be full access at the user level: chmod 700 init.sh
8. Run init.sh to create a virtual environment and install packages
9. Run run.sh to execute the python script

# Lambda function
10. cd my-lambda-layer
11. Set permissions for mklayer.sh to be full access at the user level: chmod 700 mklayer.sh
12. Run mklayer.sh
13. Upload lambda-layer.zip to S3 bucket
14. Create lambda-layer from zip file
15. Create Lambda function
    - Attach layer to function
    - Modify Lambda role to full S3 and full RDS access
    - Load files in lambda_Script directory into Lambda function
    - create .env in Lambda function