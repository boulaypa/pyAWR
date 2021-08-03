#!/usr/bin/python3
# Start pyspark via provided command
import pyspark

# Below code is Spark 2+
spark = pyspark.sql.SparkSession.builder.appName('test').getOrCreate()

spark.range(10).collect()

