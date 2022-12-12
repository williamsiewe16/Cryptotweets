// iam managed policies
data "aws_iam_policy" "AmazonS3FullAccess" {
    arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}


data "aws_iam_policy" "CloudWatchFullAccess" {
    arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

data "aws_iam_policy" "AmazonDMSRedshiftS3Role" {
    arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSRedshiftS3Role"
}

data "aws_iam_policy" "AWSGlueServiceRole" {
    arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

data "aws_iam_policy" "AmazonRedshiftFullAccess" {
    arn = "arn:aws:iam::aws:policy/AmazonRedshiftFullAccess"
}

data "aws_iam_policy" "AWSGlueConsoleFullAccess" {
    arn = "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess"
}

data "aws_iam_policy" "AWSGlueSchemaRegistryFullAccess" {
    arn = "arn:aws:iam::aws:policy/AWSGlueSchemaRegistryFullAccess"
}

data "aws_iam_policy" "AmazonRedshiftDataFullAccess" {
    arn = "arn:aws:iam::aws:policy/AmazonRedshiftDataFullAccess"
}

data "aws_iam_policy" "AmazonEC2ContainerRegistryFullAccess" {
    arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

// route table

data "aws_route_table" "route_table" {
  vpc_id = aws_vpc.cryptotweets-vpc.id
  
  depends_on = [
    aws_vpc.cryptotweets-vpc,
    aws_subnet.cryptotweets-subnet,
    /*aws_internet_gateway.internet_gateway*/
  ]
}



/*data "aws_redshift_cluster" "example" {
  cluster_identifier = "cryptotweets-cluster"
}*/
