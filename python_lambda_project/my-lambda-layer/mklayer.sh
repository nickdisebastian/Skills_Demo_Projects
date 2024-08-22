#Run this script to create the Lambda layer "lambda-layer.zip". 
#This zip file should be uploaded to Lambda layer

sudo apt install zip
mkdir -p aws-layer/python/lib/python3.12/site-packages
pip3 install -r requirements.txt --target aws-layer/python/lib/python3.12/site-packages
cd aws-layer
zip -r9 lambda-layer.zip . ./home/ubuntu/python_lambda_project/my-lambda-layer