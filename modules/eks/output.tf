# output "eks_cluster_name" {
#     value = "aws_eks_cluster.demo.name"
# }
output "cluster_role" {
    value = "aws_iam_role.demo-cluster.arn"
}
output "cluster_name" {
    value = aws_eks_cluster.demo.name
}