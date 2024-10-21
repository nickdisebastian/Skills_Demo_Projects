# Docker Lab

## Description
This project creates a Docker container for concatenating csvs using Python

## Contents
- [py_script.py] concats files in input folder and writes to output folder
- [Dockerfile] creates Docker image to run py_script.py
- [Input] folder with original csvs
- [Output] folder with concatenated file

## Running the Project
1. Add files to input folder
2. Create Image 
    - docker build -t file-concat .
3. Verify image was created
    - docker images
4. Run the Docker image
    - docker run -d --name my_container file-concat