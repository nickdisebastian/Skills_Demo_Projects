#!/bin/bash

#update packages
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install unzip

#install Python3
sudo apt-get install python3
echo $(python3 --version) successfully installed
sudo apt-get install python3-pip

###Install AZcopy
# Download and extract
wget https://aka.ms/downloadazcopy-v10-linux
tar -xvf downloadazcopy-v10-linux

# Move AzCopy
sudo rm -f /usr/bin/azcopy
sudo cp ./azcopy_linux_amd64_*/azcopy /usr/bin/
sudo chmod 755 /usr/bin/azcopy

# Remove from working directory
rm -f downloadazcopy-v10-linux
rm -rf ./azcopy_linux_amd64_*/
echo AZ copy successfully installed

#install and setup virtual environment
sudo apt install python3-venv -y
python3 -m venv venv
source venv/bin/activate

#install python packages
pip install -r requirements.txt
deactivate 
echo Python packages successfully installed

#update permissions and execute run file
chmod a+x run.sh

#make log directory
mkdir log