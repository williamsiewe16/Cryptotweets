// create a vpc
resource "aws_vpc" "cryptotweets-vpc" {
  cidr_block = "192.168.0.0/16"
  #enable_dns_hostnames = true
  tags = {
   Name = var.vpc_name
  }  
}

// create a subnet
resource "aws_subnet" "cryptotweets-subnet" {
  vpc_id     = aws_vpc.cryptotweets-vpc.id
  cidr_block = "192.168.100.0/24"
  tags = {
   Name = var.subnet_name
  }
}


//custom policies
resource "aws_iam_policy" "Add_delete_tags" {
  name = var.Add_delete_tags

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:Describe*",
                "ec2:CreateTags",
                "ec2:DeleteTags"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
  })
}

// security group for ec2, redshift, glue
resource "aws_security_group" "cryptotweets_security_group" {
  name        = var.cryptotweets_security_group
  vpc_id      = aws_vpc.cryptotweets-vpc.id

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 5439
    to_port          = 5439
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}

// create glue role
resource "aws_iam_role" "glue_role" {
  name = var.glue_role_name
  assume_role_policy = var.glue_assume_role_policy
  managed_policy_arns = [
    data.aws_iam_policy.AmazonS3FullAccess.arn,
    data.aws_iam_policy.CloudWatchFullAccess.arn,
    data.aws_iam_policy.AmazonDMSRedshiftS3Role.arn,
    data.aws_iam_policy.AWSGlueServiceRole.arn,
    data.aws_iam_policy.AmazonRedshiftFullAccess.arn,
    data.aws_iam_policy.AWSGlueConsoleFullAccess.arn,
    data.aws_iam_policy.AWSGlueSchemaRegistryFullAccess.arn,
    data.aws_iam_policy.AmazonRedshiftDataFullAccess.arn,
    aws_iam_policy.Add_delete_tags.arn
  ]
}

// create ec2 role
resource "aws_iam_role" "ec2_role" {
  name = var.ec2_role_name
  assume_role_policy = var.ec2_assume_role_policy
  managed_policy_arns = [
    data.aws_iam_policy.AmazonS3FullAccess.arn,
    data.aws_iam_policy.AWSGlueConsoleFullAccess.arn,
    data.aws_iam_policy.AmazonEC2ContainerRegistryFullAccess.arn
  ]
}

// create redshift role
resource "aws_iam_role" "redshift_role" {
  name = var.redshift_role_name
  assume_role_policy = var.redshift_assume_role_policy
  managed_policy_arns = [
    data.aws_iam_policy.AmazonS3FullAccess.arn,
  ]
}

// create lambda role
resource "aws_iam_role" "lambda_role" {
  name = var.lambda_role_name
  assume_role_policy = var.lambda_assume_role_policy
  managed_policy_arns = [
    data.aws_iam_policy.AmazonS3FullAccess.arn,
    data.aws_iam_policy.AWSGlueConsoleFullAccess.arn,
    data.aws_iam_policy.CloudWatchFullAccess.arn
  ]
}

// create vpc endpoint
resource "aws_vpc_endpoint" "vpc_endpoint" {
  service_name      = var.vpc_endpoint
  vpc_endpoint_type = "Gateway"
  vpc_id            = aws_vpc.cryptotweets-vpc.id
  route_table_ids   = [data.aws_route_table.route_table.id]

  depends_on = [
    data.aws_route_table.route_table
  ]
}


// s3 bucket
resource "aws_s3_bucket" "cryptotweets-datalake" {
  bucket = var.cryptotweets-datalake
  tags = {
    Name = var.cryptotweets-datalake
  }
}

resource "aws_s3_bucket" "lambda_layers" {
  bucket = "cryptotweets-lambda-layers"
}
// redshift cluster

resource "aws_redshift_cluster" "cryptotweets-cluster" {
  cluster_identifier = var.cryptotweets-cluster
  database_name      = var.cryptotweets-cluster-dbname
  master_username    = var.cryptotweets-cluster-user
  master_password    = var.cryptotweets-cluster-password
  node_type          = "dc2.large"
  cluster_type       = "single-node"
  #cluster_security_groups = [aws_security_group.cryptotweets_security_group.id]
  default_iam_role_arn = aws_iam_role.redshift_role.arn
  cluster_subnet_group_name = aws_subnet.cryptotweets-subnet.id
}

/*** glue ***/

// glue database
resource "aws_glue_catalog_database" "database" {
  name = var.cryptotweets-glue-dbname
}

// glue redshift connection
resource "aws_glue_connection" "cryptotrendings" {
  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:redshift://${aws_redshift_cluster.cryptotweets-cluster.endpoint}"//${aws_redshift_cluster.cryptotweets-cluster.endpoint}"//${var.cryptotweets-cluster-dbname}"
    PASSWORD            = var.cryptotweets-cluster-password
    USERNAME            = var.cryptotweets-cluster-user
  }

  name = var.cryptotweets-glue-connector

  physical_connection_requirements {
    availability_zone      = aws_subnet.cryptotweets-subnet.availability_zone
    security_group_id_list = [aws_security_group.cryptotweets_security_group.id]
    subnet_id              = aws_subnet.cryptotweets-subnet.id
  }
}

// glue crawler for redshift table
resource "aws_glue_crawler" "cryptotrendings" {
  database_name = aws_glue_catalog_database.database.name
  name          = var.cryptotrendings-crawler
  role          = aws_iam_role.glue_role.arn

  jdbc_target {
    connection_name = aws_glue_connection.cryptotrendings.name
    path            = "${var.cryptotweets-cluster-dbname}/public/${var.cryptotrendings-redshift-table}"
  }
}

// glue crawler for s3 bucket
resource "aws_glue_crawler" "cryptotweets" {
  database_name = aws_glue_catalog_database.database.name
  name          = var.cryptotweets-crawler
  role          = aws_iam_role.glue_role.arn

  s3_target {
    path = "s3://${aws_s3_bucket.cryptotweets-datalake.bucket}"
  }
}


// glue job
resource "aws_glue_job" "s3_to_redshift" {
  name     = var.cryptotweets-glue-job
  role_arn = aws_iam_role.glue_role.arn
  connections = [aws_glue_connection.cryptotrendings.arn]
  glue_version="3.0"
  number_of_workers=2
  max_retries=0

  command {
    script_location = var.glue_job_path
    python_version = "3"
  }
}

/*** Lambda Functions ***/

/* twitter scraper */

// lambda function archive
data "archive_file" "lambda_layer_zip" {
  type        = "zip"
  source_dir  = "${var.cryptotweets_twitter_scraper-layer-dir}"
  output_path = var.cryptotweets_twitter_scraper-layer-file
}

// push lambda layer to s3
resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.lambda_layers.bucket
  key    = "lambda_layer1"
  source = var.cryptotweets_twitter_scraper-layer-file
}

// lambda layer
resource "aws_lambda_layer_version" "lambda_layer" {
  #filename   = var.cryptotweets_twitter_scraper-layer-file
  layer_name = "twitter_layer"
  s3_bucket = "${aws_s3_object.object.bucket}"
  s3_key = "${aws_s3_object.object.key}"
  s3_object_version = "${aws_s3_object.object.version_id}"

  compatible_runtimes = ["python3.8"]
}

// lambda function archive
data "archive_file" "zip_the_python_code1" {
  type        = "zip"
  source_dir  = var.cryptotweets_twitter_scraper-archiveDir
  output_path = var.cryptotweets_twitter_scraper-file
}

// lambda function
resource "aws_lambda_function" "twitter_scaper_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = var.cryptotweets_twitter_scraper-file
  function_name = var.cryptotweets_twitter_scraper-name
  role          = aws_iam_role.lambda_role.arn
  handler       = "script.lambda_handler"
  runtime = "python3.9"
  timeout = 300
  layers        = [
    aws_lambda_layer_version.lambda_layer.arn
  ]
  
  environment {
    variables = {
      TWITTER_API_KEY=var.TWITTER_API_KEY
      TWITTER_API_KEY_SECRET=var.TWITTER_API_KEY_SECRET
      TWITTER_BEARER_TOKEN=var.TWITTER_BEARER_TOKEN
      TWITTER_ACCESS_TOKEN=var.TWITTER_ACCESS_TOKEN
      TWITTER_ACCESS_TOKEN_SECRET=var.TWITTER_ACCESS_TOKEN_SECRET
      TWITTER_CLIENT_ID=var.TWITTER_CLIENT_ID
      TWITTER_CLIENT_SECRET=var.TWITTER_CLIENT_SECRET
      cryptotweets_datalake=var.cryptotweets-datalake
    }
  }
}

// twitter_scraper trigger
resource "aws_cloudwatch_event_rule" "twitter_scraper_rule" {
    name = "twitter_scraper_rule"
    schedule_expression = var.cryptotweets_twitter_scraper_scheduler
}

resource "aws_cloudwatch_event_target" "twitter_scraper_target" {
    rule = aws_cloudwatch_event_rule.twitter_scraper_rule.name
    target_id = "twitter_scraper_target"
    arn = aws_lambda_function.twitter_scaper_lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_twitter_scraper" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.twitter_scaper_lambda.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.twitter_scraper_rule.arn
}

/* glue job */

// lambda function archive
data "archive_file" "zip_the_python_code2" {
type        = "zip"
source_dir  = var.cryptotweets_glue_job-archiveDir
output_path = var.cryptotweets_glue_job-file
}

// lambda function
resource "aws_lambda_function" "glue_job_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = var.cryptotweets_glue_job-file
  function_name = var.cryptotweets_glue_job-name
  role          = aws_iam_role.lambda_role.arn
  handler       = "script.lambda_handler"
  runtime = "python3.9"
  timeout = 900

  environment {
    variables = {
      foo = "bar"
    }
  }
}

// glue_job trigger
resource "aws_cloudwatch_event_rule" "glue_job_rule" {
    name = "glue_job_rule"
    schedule_expression = var.cryptotweets_glue_job_scheduler
}

resource "aws_cloudwatch_event_target" "glue_job_target" {
    rule = aws_cloudwatch_event_rule.glue_job_rule.name
    target_id = "glue_job_target"
    arn = aws_lambda_function.glue_job_lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_glue_job" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.glue_job_lambda.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.glue_job_rule.arn
}