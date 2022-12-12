#########################################
### IMPORT LIBRARIES AND SET VARIABLES
#########################################

#Import python modules
from datetime import datetime
from sys import argv

#Import pyspark modules
from pyspark.context import SparkContext
from pyspark.sql.functions import *
from pyspark.sql.types import *

#Import glue modules
from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from awsglue.dynamicframe import DynamicFrame
from awsglue.job import Job

#Initialize contexts and session
spark_context = SparkContext.getOrCreate()
glue_context = GlueContext(spark_context)
session = glue_context.spark_session

#Parameters
catalog_connector="cryptotweets-redshift-connector"
glue_db = "cryptotweets-catalog"
glue_schema = "public"
glue_tbl_source = "cryptotweets_datalake1606"
glue_tbl_dest = "cryptotrendings" #"dev_public_cryptotrendings"
s3_write_path = "s3://cryptotweets-datalake1606/"


args = getResolvedOptions(argv, ['TempDir'])


#########################################
### EXTRACT (READ DATA)
#########################################

#Log starting time
dt_start = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
print("Start time:", dt_start)

#Read movie data to Glue dynamic frame
dynamic_frame_read = glue_context.create_dynamic_frame.from_catalog(database = glue_db, table_name = glue_tbl_source)

#Convert dynamic frame to data frame to use standard pyspark functions
df = dynamic_frame_read.toDF()

#########################################
### TRANSFORM (MODIFY DATA)
#########################################

final_df = df.distinct() \
        .withColumn("crypto", explode(df.cryptos)) \
        .select(col("crypto"),to_date(col("created_at")).alias("date")) \
        .groupBy(col("date"),col("crypto")) \
        .count() \
        .withColumn("count",col("count").cast('int'))


final_df.show()


#########################################
### LOAD (WRITE DATA)
#########################################

#Convert back to dynamic frame
dynamic_frame_write = DynamicFrame.fromDF(final_df, glue_context, "dynamic_frame_write")

#glue_context.write_dynamic_frame.from_catalog(frame = dynamic_frame_write, database = glue_db, table_name = glue_tbl_dest, redshift_tmp_dir=args['TempDir'])
#glue_context.write_dynamic_frame_from_jdbc_conf(frame = dynamic_frame_write, catalog_connection = "cryptotweets-redshift-connector", 
#                connection_options = {"dbtable": glue_tbl_dest, "database": glue_db, "preactions":"TRUNCATE TABLE {}.{}".format(glue_schema,glue_tbl_dest)}, 
#                redshift_tmp_dir = args["TempDir"], 
#                transformation_ctx = "datasink5")

datasink4 = glue_context.write_dynamic_frame_from_jdbc_conf(frame=dynamic_frame_write, catalog_connection = catalog_connector, redshift_tmp_dir = args['TempDir'], transformation_ctx = "datasink4", connection_options = {"preactions": "TRUNCATE TABLE {}.{}".format(glue_schema,glue_tbl_dest),"dbtable": "{}.{}".format(glue_schema,glue_tbl_dest), "database": "dev"})

#Log end time
dt_end = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
print("Start time:", dt_end)
