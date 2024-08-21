#! usr/bin python3

#import modules
import pandas as pd
import glob
import os

#set program variables
input_path = '/Users/nickdisebastian/WeCloudDataEngineering/WCD_Assignments/mini_projects/linux_python/input'
output_path = '/Users/nickdisebastian/WeCloudDataEngineering/WCD_Assignments/mini_projects/linux_python/output'
filename = 'all_years.csv'
csvs = glob.glob(os.path.join(input_path, "*.csv"))
#test printing csvs to understand the above line

#make list of data frames from downloaded csvs
li =[]
for f in csvs:
    df = pd.read_csv(f,header = 0, index_col = None)
    li.append(df)

#union dfs to single df
df_concat = pd.concat(li, axis = 0, ignore_index=True)

#create csv form unioned dfs 
df_concat.to_csv(output_path+"/"+filename)
    