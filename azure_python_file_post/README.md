# Azure Python File Post

## Description
This project gathers job data from themuse.com and posts it as a csv to an Azure container 

## Running the Project

1. Launch and SSH into Azure VM instance
2. Create an Azure storage account and a BLOB Storage container. 
3. Within config.toml, update the API URL and the storage container URL
4. Set permissions for init.sh to be full access at the user level: `chmod 700 init.sh`
5. Run [init.sh](init.sh) to create a virtual environment and install packages
6. Run [run.sh](run.sh) to execute the python script