# Toronto Climate Data Linux Lab Project

## Description
This project downloads Toronto Climate Data from three years and concatenates the three files into a single csv. It uses 

## Contents
- [Scripts] contains the following:
     - shell-script.sh: sets file paths, sets log rules, downloads data, runs python script
     - requirements.txt: python dependencies
     - python-script.py: concats csvs and writes to output folder
- [Input] folder with three downloaded files
- [Output] folder with concatenated file

## Running the project
1. Make the scripts executable
     - chmod +x shell-script.sh
2. Run the shell script
     - ./shell-script.sh

