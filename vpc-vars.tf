variable "cidr" {
    type = string
    description = "CIDR range of the VPC"
}

variable "enable_dns_hostnames" {
    type = bool
    default = true
}

variable "enable_dns_support" {
    type = bool
    default = true
}

variable "map_public_ip_on_launch" {
    type = bool
    description = "Map public ip"
    default = true
}

variable "public_subnets" {
    type = list
    description = "cidr of subnets"
}

variable "availability_zone" {
    type = list
    description = "list of availability zones"
}

variable "public_subnet_tags" {
    default = {
        Name = [
            "james-prod-web-pub-subnet-a",
            "james-prod-web-pub-subnet-b",
            "james-prod-web-pub-subnet-c"
        ]
    }
}

variable "instance_name" {
    default = {
        Name = [
            "james-prod-web-01",
            "james-prod-web-02",
            "james-prod-web-03"
        ]
    }
}

variable "subnets" {
    type = list(string)
    default = ["10.0.0.0/28", "10.0.208.0/28", "10.0.244.0/28"]
}

variable "key_name" {
    type = string
    default = "servers"
}