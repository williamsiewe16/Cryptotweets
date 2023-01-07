variable "TWITTER_API_KEY" {}
variable "TWITTER_API_KEY_SECRET" {}
variable "TWITTER_BEARER_TOKEN" {}
variable "TWITTER_ACCESS_TOKEN" {}
variable "TWITTER_ACCESS_TOKEN_SECRET" {}
variable "TWITTER_CLIENT_ID" {}
variable "TWITTER_CLIENT_SECRET" {}

variable "AWS_KEY" {}
variable "AWS_SECRET" {}
variable "AWS_REGION" {}

//iam roles
variable "glue_assume_role_policy" {
  type=string
  default = <<EOF
              {
                "Version": "2012-10-17",
                "Statement": [
                  {
                    "Action": "sts:AssumeRole",
                    "Principal": {
                      "Service": "glue.amazonaws.com"
                    },
                    "Effect": "Allow",
                    "Sid": ""
                  }
                ]
              }
            EOF
}

variable "ec2_assume_role_policy" {
  type=string
  default = <<EOF
              {
                  "Version": "2012-10-17",
                  "Statement": [
                      {
                          "Effect": "Allow",
                          "Principal": {
                              "Service": "ec2.amazonaws.com"
                          },
                          "Action": "sts:AssumeRole"
                      }
                  ]
              }
            EOF
}


variable "redshift_assume_role_policy" {
  type=string
  default = <<EOF
              {
                  "Version": "2012-10-17",
                  "Statement": [
                      {
                          "Effect": "Allow",
                          "Principal": {
                              "Service": "redshift.amazonaws.com"
                          },
                          "Action": "sts:AssumeRole"
                      }
                  ]
              }
            EOF
}

variable "lambda_assume_role_policy" {
  type=string
  default = <<EOF
              {
                  "Version": "2012-10-17",
                  "Statement": [
                      {
                          "Effect": "Allow",
                          "Principal": {
                              "Service": "lambda.amazonaws.com"
                          },
                          "Action": "sts:AssumeRole"
                      }
                  ]
              }
            EOF
}


variable "ec2_role_name" {}
variable "redshift_role_name" {}
variable "glue_role_name" {}
variable "lambda_role_name" {}
variable "Add_delete_tags" {}


// security group
variable "cryptotweets_security_group" {}


// vpc
variable "vpc_name" {}

// subnet
variable "subnet_name" {}

variable "subnet_id" {}

// vpc endpoint
variable "vpc_endpoint" {}

// s3
variable "cryptotweets-datalake" {}


// redshift
variable "cryptotweets-cluster" {}
variable "cryptotweets-cluster-dbname" {}
variable "cryptotweets-cluster-user" {}
variable "cryptotweets-cluster-password" {}
variable "cryptotrendings-redshift-table" {}


// glue
variable "cryptotweets-glue-dbname" {}
variable "cryptotweets-crawler" {}
variable "cryptotrendings-crawler" {}
variable "cryptotweets-glue-connector" {}
variable "cryptotweets-glue-job" {}
variable "glue_job_path" {}

// lambda
variable "cryptotweets_glue_job-name" {}
variable "cryptotweets_glue_job-file" {}
variable "cryptotweets_glue_job-archiveDir" {}
variable "cryptotweets_glue_job_scheduler" {}
variable "cryptotweets_twitter_scraper-name" {}
variable "cryptotweets_twitter_scraper-file" {}
variable "cryptotweets_twitter_scraper-archiveDir" {}
variable "cryptotweets_twitter_scraper-layer-file" {}
variable "cryptotweets_twitter_scraper-layer-dir" {}
variable "cryptotweets_twitter_scraper_scheduler" {}


// EC2 for twitter scraper
variable "ec2-name" {}
variable "ami" {}
variable "instance_type" {}
variable "igw-name" {}