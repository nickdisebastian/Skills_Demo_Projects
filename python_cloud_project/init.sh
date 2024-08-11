#!/bin/bash

#update packages
sudo apt update
sudo apt upgrade
sudo apt install unzip

#install Python3
sudo apt install python3
echo $(python3 --version) installed successfully
sudo apt install python3-pip

#install aws-cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm awscliv2.zip 
rm -r aws
echo $(aws --version) installed successfully


#install and setup virtual environment
sudo apt install python3-venv
python3 -m venv venv
source venv/bin/activate

#install python packages
pip install -r requirements.txt
deactivate 

#update permissions and execute run file
chmod a+x run.sh

#make log directory
mkdir log



