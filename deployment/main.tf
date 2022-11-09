// EC2 for twitter scraper

resource "aws_instance" "twitter-scraper" {
  ami           = var.ami
  instance_type = var.instance_type


  credit_specification {
    cpu_credits = "standard"
  }
}