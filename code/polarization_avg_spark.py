from pyspark import SparkConf, SparkContext
from pyspark.sql import functions as F
from pyspark.sql import SparkSession
import string
import sys
import os
import matplotlib.pyplot as plt
import numpy as np


# Take as argument a directory name 
directory = sys.argv[1]


#Set up the Spark session
conf = SparkConf().setMaster('local').setAppName('Polarization Calculator')
sc = SparkContext(conf = conf)
spark = SparkSession(sc)



#Read in CSVs to a single RDD

#CSV structure will look like this:
# "simnum" | "simtime" | "simtype" | list of times        | 
# simnum | simtime | type of calc | calc_1 at all times  | 
# ...
# simnum | simtime | type of calc | calc_N at all times  | 
df = spark.read.option("header", "true").csv(directory + '/' + '*data.csv')

#Grab times
times = df.columns[3:]

#Print size of dataframe
print((df.count(), len(df.columns)))


#Modify times for processing as column names
times_mod = ['`' + str + '`' for str in times]

#Cast polarization expectation values to float and rename columns to avoid dealing with decimal number names
df = df.select("simtype", *(df[times_mod[i]].cast("float").alias('c'+str(i)) for i in range(len(times_mod))))


#Find new list of column names for the time columns
cols = df.columns[1:]

#Find averages by polarization type
dfavgs = df.groupBy("simtype").mean()

dfavgs.show()

#save results
###df.coalesce(1).write.format("com.databricks.spark.csv").option("header", "true").save("mydata.csv")

#Create measurement key
msmt_key = {
    1 : "X",
    2 : "Y",
    3 : "Z",
}

#Make figure, plot, and save 
fig2 = plt.figure()

for i in msmt_key.keys(): 
    mydfavgs = dfavgs.filter(dfavgs.simtype==i)
    avgs = np.array(mydfavgs.collect())
    avgs = avgs[0][1:]

    plt.plot(times, avgs, label = msmt_key[i])

label_size = 20
label_size2 = 20
label_size3 = 20
label_size4 = 15

plt.xlabel(r't', fontsize = label_size3)
plt.ylabel(r'Polarization', fontsize = label_size3)
plt.legend(fontsize = label_size4, ncol = 2)
plt.ylim([0,1])
plt.title(r'Averaged Polarization', fontsize = label_size3)

save_loc = 'plots'
if not os.path.isdir(save_loc): 
    os.mkdir(save_loc)
plt.savefig(save_loc + "/polarization_plot_spark.pdf",bbox_inches = "tight")

plt.show()
plt.close()



