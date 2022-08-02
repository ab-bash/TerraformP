# data "aws_vpc" "vpc-data" {
#   filter {
#     name = "tag:Name"
#     values = ["${var.vpc-name}"]
#   }
#   depends_on = [aws_vpc.eks-vpc]
# }

output "vpc_id" {
  #value = "data.aws_vpc.vpc-data.id"
  value = aws_vpc.eks-vpc.id
}

output "public_subnet_id" {
    value = aws_subnet.public-subnet.*.id
}