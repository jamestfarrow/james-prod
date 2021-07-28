resource "aws_vpc" "james-prod-vpc" {
    cidr_block = var.cidr
    enable_dns_hostnames = var.enable_dns_hostnames
    enable_dns_support = var.enable_dns_support
    tags = {
        Name = "james-prod-vpc"
    }
}

resource "aws_subnet" "public" {
    count = length(var.public_subnets)
    vpc_id = aws_vpc.james-prod-vpc.id
    cidr_block = element(var.public_subnets,count.index)
    availability_zone = element(var.availability_zone,count.index)
    map_public_ip_on_launch = var.map_public_ip_on_launch
    tags = {
        Name = var.public_subnet_tags["Name"][count.index]
    }
}

resource "aws_internet_gateway" "james-igw" {
    vpc_id = aws_vpc.james-prod-vpc.id
    tags = {
        Name = "james-prod-igw"
    }
}

resource "aws_route_table" "prod" {
    vpc_id = aws_vpc.james-prod-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.james-igw.id
    }
    tags = {
        Name = "james-prod-web-pub-rtbl"
    }
}

resource "aws_route_table_association" "james-prod-pub" {
    count = length(var.public_subnets)
    subnet_id = element(aws_subnet.public.*.id,count.index)
    route_table_id = aws_route_table.prod.id
}

resource "aws_main_route_table_association" "james-prod-rtbl" {
    vpc_id = aws_vpc.james-prod-vpc.id
    route_table_id = aws_route_table.prod.id
}

resource "aws_security_group" "webservers" {
    name = "james-prod-web-sg"
    description = "allow web inbound traffic"
    vpc_id = aws_vpc.james-prod-vpc.id

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "james-prod-web-sg"
    }
}

resource "tls_private_key" "web-prod" {
    algorithm = "RSA"
    rsa_bits = 4096
}
resource "aws_key_pair" "servers" {
    key_name = var.key_name
    public_key = tls_private_key.web-prod.public_key_openssh
}

resource "aws_instance" "webservers" {
    count = length(var.subnets)
    ami = "ami-03ac5a9b225e99b02"
	instance_type = "t2.micro"
	security_groups = [aws_security_group.webservers.id]
	subnet_id = element(aws_subnet.public.*.id,count.index)
    user_data = (file("httpd.sh"))
    key_name = aws_key_pair.servers.id

    tags = {
        Name = var.instance_name["Name"][count.index]
    }
}

resource "aws_lb" "james-prod-web" {
    name = "james-prod-web-elb"
    internal = false
    load_balancer_type = "application"
    security_groups = [aws_security_group.webservers.id]
    subnets = aws_subnet.public.*.id

    enable_deletion_protection = true
    tags = {
        Environment = "production"
    }
}