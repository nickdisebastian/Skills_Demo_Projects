#!/bin/bash

################################################
#SET DEFAULT VARIABLES
filenametime1=$(date +"%m%d%Y%H%M%S")

################################################
#SET PROGRAM VARIABLES
export BASE_FOLDER='/Users/nickdisebastian/WeCloudDataEngineering/WCD_Assignments/mini_projects/linux_lab'
export SCRIPTS_FOLDER='/Users/nickdisebastian/WeCloudDataEngineering/WCD_Assignments/mini_projects/linux_lab/scripts'
export INPUT_FOLDER='/Users/nickdisebastian/WeCloudDataEngineering/WCD_Assignments/mini_projects/linux_lab/input'
export OUTPUT_FOLDER='/Users/nickdisebastian/WeCloudDataEngineering/WCD_Assignments/mini_projects/linux_lab/output'
export LOG_FOLDER='/Users/nickdisebastian/WeCloudDataEngineering/WCD_Assignments/mini_projects/linux_lab/logs'
export SHELL_SCRIPT_NAME='shell-script'
export LOG_FILE=${LOG_FOLDER}/${SHELL_SCRIPT_NAME}_${filenametime1}.log
export VENV_DIR='venv'

################################################
#SET LOG RULES
exec > >(tee ${LOG_FILE}) 2>&1

################################################
#DOWNLOAD DATA
echo "Start data download"

for year in {2020..2022}; 
do wget --content-disposition "https://climate.weather.gc.ca/climate_data/bulk_data_e.html?format=csv&stationID=48549&Year=${year}&Month=2&Day=14&timeframe=1&submit= Download+Data" -O ${INPUT_FOLDER}/${year}.csv;
done;

RC1=$?
if [ $RC1 != 0 ]; then
    echo "DOWNLOAD DATA FAILED"
    echo "[ERROR:] RETURN CODE ${RC1}"
    echo "[ERROR:] REFER TO THE LOG FOR FAILURE REASON."
    exit 1
fi 

################################################
#### CREATE VIRTUAL ENVIRONMENT & INSTALL DEPENDENCIES

if [ ! -d "$VENV_DIR" ]; then
    python3 -m venv $VENV_DIR
    echo "Virtual environment created."
else
    echo "Virtual environment already exists."
fi

source  $VENV_DIR/bin/activate

pip install -r requirements.txt

################################################
#RUN PYTHON SCRIPT
echo "Start running python script"
python3 ${SCRIPTS_FOLDER}/python-script.py

RC1=$?
if [ $RC1 != 0 ]; then
    echo "DATA CONCAT FAILED"
    echo "[ERROR:] RETURN CODE ${RC1}"
    echo "[ERROR:] REFER TO THE LOG FOR FAILURE REASON."
    exit 1
fi 

echo "PROGRAM RAN SUCCESSFULLY"

exit 0