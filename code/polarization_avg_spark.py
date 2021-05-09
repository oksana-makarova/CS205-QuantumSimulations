from pyspark import SparkConf, SparkContext
from pyspark.sql import functions as F
from pyspark.sql import SparkSession
import string
import sys
import numpy as np
import time


# Start the timer
t1 = time.clock()

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
#print((df.count(), len(df.columns)))


#Modify times for processing as column names
times_mod = ['`' + st + '`' for st in times]

#Cast polarization expectation values to float and rename columns to avoid dealing with decimal number names
df = df.select("simtype", *(df[times_mod[i]].cast("float").alias('c'+str(i)) for i in range(len(times_mod))))


#Find new list of column names for the time columns
cols = df.columns[1:]

#Find averages by polarization type
dfavgs = df.groupBy("simtype").mean()
#dfavgs.show()

#save results
dfavgs.coalesce(1).write.format("com.databricks.spark.csv").option("header", "true").save(directory + "/polarizations_spark.csv")
times = np.array(times)
times = times.astype(np.float)
np.savetxt(directory + "/times_spark.csv", times, delimiter=",")

#in command line: 
# cat polarizations_spark.csv/*




#Stop the timer and print the elapsed time
t2 = time.clock()

print('Time elapsed: ' + str(t2-t1))

