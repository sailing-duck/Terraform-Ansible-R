data "aws_availability_zones" "az" {}

resource "aws_vpc" "lewis_vpc" {
    cidr_block = var.vpc_cidr

    tags = {
        Name = "lewis_vpc"
    }
}

resource "aws_internet_gateway" "lewis_igw" {
    vpc_id = aws_vpc.lewis_vpc.id

    tags = {
        Name = "lewis_igw"
    }

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_route_table" "lewis_public_rt" {
    vpc_id = aws_vpc.lewis_vpc.id

    tags = {
        Name = "lewis_public_rt"
    }
}

resource "aws_route" "public_routes" {
    route_table_id = aws_route_table.lewis_public_rt.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lewis_igw.id
}

resource "aws_route_table" "lewis_private_rt" {
    vpc_id = aws_vpc.lewis_vpc.id

    tags = {
        Name = "lewis_private_rt"
    }
}

resource "aws_subnet" "lewis_public_subnet" {
    count = var.public_subnet_count

    vpc_id = aws_vpc.lewis_vpc.id
    cidr_block = cidrsubnet(var.vpc_cidr, 8 , count.index)
    map_public_ip_on_launch = true
    availability_zone = data.aws_availability_zones.az.names[count.index]

    tags = {
        Name = "public_subnet_${count.index}"
    }
}

resource "aws_subnet" "lewis_private_subnet" {
    count = var.private_subnet_count

    vpc_id = aws_vpc.lewis_vpc.id
    cidr_block = cidrsubnet(var.vpc_cidr, 8 , var.public_subnet_count + count.index)
    map_public_ip_on_launch = false
    availability_zone = data.aws_availability_zones.az.names[count.index]

    tags = {
      Name = "private_subnet_${count.index}"
    }
}

resource "aws_route_table_association" "lewis_public_association" {
    count = var.public_subnet_count

    subnet_id = aws_subnet.lewis_public_subnet[count.index].id
    route_table_id = aws_route_table.lewis_public_rt.id
}


resource "aws_security_group" "lewis_ec2_sg" {
    name = "ec2_sg"
    description = "sg for my ec2 instance"
    vpc_id = aws_vpc.lewis_vpc.id
}

resource "aws_security_group_rule" "in_22" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    security_group_id = aws_security_group.lewis_ec2_sg.id
}

resource "aws_security_group_rule" "in_80" {
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    security_group_id = aws_security_group.lewis_ec2_sg.id
}

resource "aws_security_group_rule" "in_8787" {
    type = "ingress"
    from_port = 8787
    to_port = 8787
    protocol = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    security_group_id = aws_security_group.lewis_ec2_sg.id
}

resource "aws_security_group_rule" "all_out" {
    type = "egress"
    from_port = 0
    to_port = 65535
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.lewis_ec2_sg.id

}

resource "aws_security_group_rule" "self_referencing" {
    type = "ingress"
    from_port = 0
    to_port = 65535
    protocol = "-1"
    security_group_id = aws_security_group.lewis_ec2_sg.id
    source_security_group_id = aws_security_group.lewis_ec2_sg.id
}