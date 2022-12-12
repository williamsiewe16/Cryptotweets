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

// redshift cluster
/*
resource "aws_redshift_cluster" "cryptotweets-cluster" {
  cluster_identifier = var.cryptotweets-cluster
  database_name      = var.cryptotweets-cluster-dbname
  master_username    = var.cryptotweets-cluster-user
  master_password    = var.cryptotweets-cluster-password
  node_type          = "dc2.large"
  clucluster_type    = "single-node"
  cluster_security_groups = [aws_security_group.cryptotweets_security_group.id]
  default_iam_role_arn = aws_iam_role.redshift_role.arn
  cluster_subnet_group_name = aws_subnet.cryptotweets-subnet.id
}

*/

/*** glue ***/
/*
// glue database
resource "aws_glue_catalog_database" "database" {
  name = var.cryptotweets-glue-dbname
}

// glue redshift connection
resource "aws_glue_connection" "cryptotrendings" {
  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:redshift://${data.aws_redshift_cluster.example.endpoint}"//${aws_redshift_cluster.cryptotweets-cluster.endpoint}"//${var.cryptotweets-cluster-dbname}"
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
    script_location = "../glue_job.py"
    python_version = "3"
  }
}


// ECR repository
resource "aws_ecr_repository" "repo" {
  name = var.cryptotweets-ecr-repository
}*/

/*** Lambda Functions ***/

data "archive_file" "zip_the_python_code1" {
type        = "zip"
source_dir  = var.cryptotweets_twitter_scraper-archiveDir
output_path = var.cryptotweets_twitter_scraper-file
}

// twitter scraper
resource "aws_lambda_function" "twitter_scaper_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = var.cryptotweets_twitter_scraper-file
  function_name = var.cryptotweets_twitter_scraper-name
  role          = aws_iam_role.lambda_role.arn
  handler       = "script.lambda_handler"
  runtime = "python3.8"

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


data "archive_file" "zip_the_python_code2" {
type        = "zip"
source_dir  = var.cryptotweets_glue_job-archiveDir
output_path = var.cryptotweets_glue_job-file
}

// glue job
resource "aws_lambda_function" "glue_job_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = var.cryptotweets_glue_job-file
  function_name = var.cryptotweets_glue_job-name
  role          = aws_iam_role.lambda_role.arn
  handler       = "script.lambda_handler"
  runtime = "python3.8"

  environment {
    variables = {
      foo = "bar"
    }
  }
}


/***  EC2 Orchestrator *****/
/*
// ec2 instance profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2_role.name
}

// ssh key
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "ec2_key" {
  content = tls_private_key.example.private_key_pem
  filename = "ec2_key.pem"
  file_permission = "400"
}

// aws key pair
resource "aws_key_pair" "generated_key" {
  key_name   = "my_key"
  public_key = tls_private_key.example.public_key_openssh
}

// internet gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.cryptotweets-vpc.id
  tags = {
    Name = var.igw-name
  }
}

// add aws route to our route table
resource "aws_route" "route" {
  route_table_id              = data.aws_route_table.route_table.id
  destination_cidr_block      = "0.0.0.0/0"
  gateway_id                  = aws_internet_gateway.internet_gateway.id
}


// EC2 instance
resource "aws_instance" "orchestrator" {
  ami           = var.ami
  instance_type = var.instance_type

  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  vpc_security_group_ids = [aws_security_group.cryptotweets_security_group.id]
  subnet_id = aws_subnet.cryptotweets-subnet.id
  key_name = aws_key_pair.generated_key.key_name
  user_data = "${file("../user_data.sh")}"
  
  tags = {
    Name = var.ec2-name
  }

  credit_specification {
    cpu_credits = "standard"
  }

}


// copy files to ec2
resource "null_resource" "copy_files" {

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${local_file.ec2_key.filename}")
    host        = "${aws_instance.orchestrator.public_ip}"
  }

  provisioner "remote-exec" {
    inline = [
      //"sudo mkdir -p /home/ubuntu/airflow/dags",
      "sudo mkdir -p /app",
      "sudo chmod 777 /app",
      "sudo chmod 777 /home/ubuntu/airflow",
      "echo AIRFLOW_HOME=/home/ubuntu/airflow | sudo tee -a /etc/environment",
      "echo TWITTER_API_KEY=${var.TWITTER_API_KEY} | sudo tee -a /etc/environment",
      "echo TWITTER_API_KEY_SECRET=${var.TWITTER_API_KEY_SECRET} | sudo tee -a /etc/environment",
      "echo TWITTER_BEARER_TOKEN=${var.TWITTER_BEARER_TOKEN} | sudo tee -a /etc/environment",
      "echo TWITTER_ACCESS_TOKEN=${var.TWITTER_ACCESS_TOKEN} | sudo tee -a /etc/environment",
      "echo TWITTER_ACCESS_TOKEN_SECRET=${var.TWITTER_ACCESS_TOKEN_SECRET} | sudo tee -a /etc/environment",
      "echo TWITTER_CLIENT_ID=${var.TWITTER_CLIENT_ID} | sudo tee -a /etc/environment",
      "echo TWITTER_CLIENT_SECRET=${var.TWITTER_CLIENT_SECRET} | sudo tee -a /etc/environment",
      "echo cryptotweets_datalake=${var.cryptotweets-datalake} | sudo tee -a /etc/environment",
    ]
  }

  
  provisioner "file" {
    source      = "../dags"
    destination = "/app/"
  }

  provisioner "file" {
    source      = "../twitter_scraper"
    destination = "/app/"
  }
 
  
  provisioner "remote-exec" {
    script = "../exec_on_ec2.sh"
  }


  depends_on = [ aws_instance.orchestrator ]

}
*/