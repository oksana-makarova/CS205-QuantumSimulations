import sys
import os
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

#### Take as argument a directory name 
directory = sys.argv[1]

#### Grab list of files
filelocs = []; 
for file in os.listdir(directory):
    if file.endswith("data.csv"):
        filelocs.append('test/' + file);

print(filelocs)

df = pd.read_csv(filelocs[0])
for f in filelocs[1:]:
    #CSV structure will look like this:
    # "simnum" | "simtime" | "simtype" | list of times        | 
    # simnum | simtime | type of calc | calc_1 at all times  | 
    # ...
    # simnum | simtime | type of calc | calc_N at all times  | 
    ndat = pd.read_csv(f)
    df = pd.concat([df, ndat])

print(df.head)


#### Average across time each polarization result
dfavgs = df.groupby(by="simtype").mean()

print(dfavgs)

#### Plot polarization over time

label_size = 20
label_size2 = 20
label_size3 = 20
label_size4 = 15

#Grab data 
print(df.columns[3:])

times = df.columns[3:]

msmt_key = {
    1 : "X",
    2 : "Y",
    3 : "Z",
}

fig2 = plt.figure()

for i in msmt_key.keys(): 
    mydfavgs = dfavgs[dfavgs.index ==i].values[0][2:]
    print(mydfavgs)
    plt.plot(times, mydfavgs, label = msmt_key[i])


plt.xlabel(r't', fontsize = label_size3)
plt.ylabel(r'Polarization', fontsize = label_size3)
plt.legend(fontsize = label_size4, ncol = 2)
plt.ylim([0,1])

# # plot
plt.title(r'Averaged Polarization', fontsize = label_size3)

save_loc = 'plots'
if not os.path.isdir(save_loc): 
    os.mkdir(save_loc)
plt.savefig(save_loc + "/polarization_plot_pandas.pdf",bbox_inches = "tight")

plt.show()
plt.close()