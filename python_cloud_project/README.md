# Python Cloud Job

## Project Description
This project pulls 50 jobs and their description from https://www.themuse.com/developers/api/v2. It then manipulates the data and stores it as a csv into an AWS S3 bucket. It is meant to be deployed within an AWS EC2 instance with an Ubunutu AMI.

## Running the Project
1. Launch and SSH into EC2 instance  
2. Creat S3 bucket
4. Create IAM AWS Service role with full s3 access and attach role to EC2 instance
2. Within config.toml, update the API URL and the AWS S3 bucket name
4. Set permissions for init.sh to be full access at the user level: chmod 700 init.sh
5. Run init.sh to create a virtual environment and install packages
6. Run run.sh to execute the python script
