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

variable "ec2_role_name" {
  type = string
  default = "ec2_role"
}

variable "redshift_role_name" {
  type = string
  default = "redshift_role"
}

variable "glue_role_name" {
  type = string
  default = "glue_role"
}

variable "Add_delete_tags" {
  type = string
  default = "Add_delete_tags_"
}


// security group
variable "cryptotweets_security_group" {
  type=string
  default = "cryptotweets_security_group"
}


// vpc
variable "vpc_name" {
  type = string
  default = "cryptotweets-vpc"
}

// subnet
variable "subnet_name" {
  type = string
  default = "cryptotweets-vpc"
}

variable "subnet_id" {
  type = string
  default = "subnet-0a856a0dee72cc30d"
}

// vpc endpoint
variable "vpc_endpoint" {
  type = string
  default = "com.amazonaws.eu-west-3.s3"
}

// s3
variable "cryptotweets-datalake" {
  type = string
  default = "cryptotweets-datalake1607"
}


// redshift
variable "cryptotweets-cluster" {
  default = "cryptotweets-cluster"
}

variable "cryptotweets-cluster-dbname" {
  default = "dev"
}

variable "cryptotweets-cluster-user" {
  default = "awsuser"
}

variable "cryptotweets-cluster-password" {
  default = "Bonjour1606"
}

variable "cryptotrendings-redshift-table" {
  default = "cryptotrendings"
}


// glue
variable "cryptotweets-glue-dbname" {
  default = "cryptotweets_catalog"
}

variable "cryptotweets-crawler" {
  default = "cryptotweets_crawler"
}

variable "cryptotrendings-crawler" {
  default = "cryptotrendings_crawler"
}

variable "cryptotweets-glue-connector" {
  default = "cryptotweets-redshift-connector_"
}

variable "cryptotweets-glue-job" {
  default = "s3_to_redshift_"
}


// ECR
variable "cryptotweets-ecr-repository" {
  default = "cryptotweets-orchestrator"
}


// EC2 for twitter scraper
variable "ec2-name" {
  type = string
  default = "cryptotweets-orchestrator"
}

variable "ami" {
    type = string
    default = "ami-0493936afbe820b28"
}

variable "instance_type" {
    type = string
    default = "t2.micro"
}

variable "igw-name" {
  type = string
  default = "cryptotweets-igw"
}