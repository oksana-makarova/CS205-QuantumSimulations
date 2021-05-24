import sys
import os
import pandas as pd
import numpy as np
import time

t1 = time.clock()

#### Take as argument a directory name 
directory = sys.argv[1]

#### Grab list of files
filelocs = []; 
for file in os.listdir(directory):
    if file.endswith("data.csv"):
        filelocs.append(directory + '/' + file);

#print(filelocs)

### Read in CSVs to a single dataframe
df = pd.read_csv(filelocs[0])
for f in filelocs[1:]:
    #CSV structure will look like this:
    # "simnum" | "simtime" | "simtype" | list of times        | 
    # simnum | simtime | type of calc | calc_1 at all times  | 
    # ...
    # simnum | simtime | type of calc | calc_N at all times  | 
    ndat = pd.read_csv(f)
    df = pd.concat([df, ndat])

#print(df.head)


#### Average across time each polarization result
dfavgs = df.groupby(by="simtype").mean()

dfavgs = dfavgs.drop(columns='Simnum').drop(columns='Simtime')

### save to CSV
dfavgs.to_csv(directory + "/polarizations_pandas.csv")
times = df.columns[3:]
times = np.array(times.values)
times = times.astype(np.float)
np.savetxt(directory + "/times_pandas.csv", times, delimiter=",")



t2 = time.clock()

print('Time elapsed: ' + str(t2-t1))