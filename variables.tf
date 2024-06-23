variable "vpc_cidr" {
    type = string
}

variable "public_subnet_count" {
    type = number
}

variable "private_subnet_count" {
    type = number
}

variable "allowed_cidr_blocks" {
    type = list(string)
}