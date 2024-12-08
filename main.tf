provider "aws" {
    region = "us-east-1"
}

data "aws_vpc" "default" {
    default = true
}

# data "aws_subnet" "" {
#     vpc_id = data.aws_vpc.default
# }