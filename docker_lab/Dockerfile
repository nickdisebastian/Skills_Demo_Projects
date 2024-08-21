# reference base image
FROM python:3.7-slim

#create work folder
WORKDIR /app

# Copyfiles to working dir
COPY py_script.py requirements.txt /app/

# install dependencies
RUN pip install -r requirements.txt

#create container volume mounting to host dir for py script to read and write data from host
VOLUME /app/input
VOLUME /app/output

#create environment variables for python script
ENV INPUT_DIR='/app/input'
ENV OUTPUT_DIR='/app/output'

#keep container running
CMD tail -f /dev/null  

# run the following command in docker exec to run the python script. python3:
# docker exec -it <docker container id> python3 <python script file name>