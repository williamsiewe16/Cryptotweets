/****************************************************/ 
/*                   AWS CREDENTIALS                */
/****************************************************/
AWS_KEY="***"
AWS_SECRET="***"
AWS_REGION="eu-west-3"



/********************************************************/ 
/*                TWITTER API CRENDENTIALS              */
/********************************************************/
TWITTER_API_KEY="***"
TWITTER_API_KEY_SECRET="***"
TWITTER_BEARER_TOKEN="***"
TWITTER_ACCESS_TOKEN="***"
TWITTER_ACCESS_TOKEN_SECRET="***"
TWITTER_CLIENT_ID="***"
TWITTER_CLIENT_SECRET="***"



/****************************************************/ 
/*            INFRASTRUCTURE CONFIGURATION          */
/****************************************************/

// iam
ec2_role_name="ec2_role"
redshift_role_name="redshift_role"
glue_role_name="glue_role"
lambda_role_name="lambda_role"
Add_delete_tags="Add_delete_tags_"

// security group
cryptotweets_security_group="cryptotweets_security_group"

// vpc
vpc_name="cryptotweets-vpc"

// subnet
subnet_name="cryptotweets-vpc"
subnet_id="subnet-0a856a0dee72cc30d"
vpc_endpoint="com.amazonaws.eu-west-3.s3"
igw-name="cryptotweets-igw"

// s3
cryptotweets-datalake="cryptotweets-datalake1607"

// redshift
cryptotweets-cluster="cryptotweets-cluster"
cryptotweets-cluster-dbname="dev"
cryptotweets-cluster-user="awsuser"
cryptotweets-cluster-password="Bonjour1606"
cryptotrendings-redshift-table="cryptotrendings"

// glue
cryptotweets-glue-dbname="cryptotweets_catalog"
cryptotweets-crawler="cryptotweets_crawler"
cryptotrendings-crawler="cryptotrendings_crawler"
cryptotweets-glue-connector="cryptotweets-redshift-connector_"
cryptotweets-glue-job="s3_to_redshift_"
glue_job_path="../glue_job.py"

// lambda
cryptotweets_glue_job-name="cryptotweets_glue_job"
cryptotweets_glue_job-file="../lambda/cryptotweets_glue_job/script.zip"
cryptotweets_glue_job-archiveDir="../lambda/cryptotweets_glue_job"
cryptotweets_glue_job_scheduler="rate(12 hours)"

cryptotweets_twitter_scraper-name="cryptotweets_twitter_scraper"
cryptotweets_twitter_scraper-file="../lambda/cryptotweets_twitter_scraper/script.zip"
cryptotweets_twitter_scraper-archiveDir="../lambda/cryptotweets_twitter_scraper"
cryptotweets_twitter_scraper-layer-dir="../lambda/tmp/"
cryptotweets_twitter_scraper-layer-file="../lambda/layers/twitter_layer.zip"
cryptotweets_twitter_scraper_scheduler="rate(12 hours)"

// EC2 for twitter scraper
ec2-name="cryptotweets-orchestrator"
ami="ami-0493936afbe820b28"
instance_type="t2.micro"