provider "aws" {
    region = "eu-west-2"
}

module "vpc" {
    source = "./vpc"
    cidr = "10.0.0.0/16"
    public_subnets = ["10.0.0.0/28", "10.0.208.0/28", "10.0.244.0/28"]
    availability_zone = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}