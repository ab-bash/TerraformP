resource "aws_iam_role" "worker-role" {
  name = "worker-node-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "demo-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.worker-role.name
}

resource "aws_iam_role_policy_attachment" "demo-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.worker-role.name
}

resource "aws_iam_role_policy_attachment" "demo-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.worker-role.name
}

resource "aws_eks_node_group" "demo" {
  cluster_name    = var.cluster-name
  node_group_name = var.node-group-name
  node_role_arn   = aws_iam_role.worker-role.arn
  subnet_ids      = var.public-subnet
  instance_types = var.instance-type
  #ec2_sshs_key = aws_key_pair.key.id
  #ami_type = var.ami
  disk_size = var.node-disk-size
  capacity_type = var.capacity-type
  
  

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 2
    #launch_template_id = aws_launch_template.eks_node_with_keypair.id
  }

  # remote_access {
  #   #ec2_ssh_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDxjzfWw0Nz+AoER7s6SylTiDoB9u5LqNlDHCCEft5tSrjtMfsuSGp4G7x4xOJgGakvbfo753hmTYeXBtFO3xXiv6M3V7qbJye9W/eJl7IvewTE7/LgwSIEIOIUDgtKcsyZ9N02brR3374Js+4Oh5w/EZ57Hayomt+WKZ4hM45MzuKHokJP3BiYsWPwDJc/o8fjXF4Sny8XVLJ81AUBP2W1Of1zRwJuVvSyT1zOibFkkgn07CeQoKqCcDOuRMFZgZ0TfGw7R18eONgCOeaKtVhD3Zpgw7R5F7jC5QMjAFTaB5NAOmMFfITW/thKBXCq+8gCbioNdebqY8OSG51pS92W7PqwbVmQYsPZiO4Z/ZhLqex+I4uxtcTm5PSmMf6S9Ct50OF26XlnQwK+aF4c455uHWorlrzDWcpeotJ9He+6LxwlhcwWvUTnwToUGhaqKYjY3CVIl9NQat8/TPKh60cCR5m4M632aeUymLzGMfUTrF2hAqDtRtysBqJmEX8EnIM= opstree@opstree-Latitude-3410"
  #   source_security_group_ids = ["aws_security_group.worker-sg.id"]
  # }




  depends_on = [
    aws_iam_role_policy_attachment.demo-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.demo-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.demo-node-AmazonEC2ContainerRegistryReadOnly,
  ]
  tags = {
    "Name" = "worker-node"
  }
}


resource "aws_security_group" "worker-sg"{
    name = "worker-sg"
    vpc_id = var.vpc-id

    ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
      from_port = 0
      to_port = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
}

# resource "aws_key_pair" "key" {
#   key_name   = "eks"
#   public_key = file(var.key-pair)
# }




# resource "aws_key_pair" "eks_key" {
#   key_name   = "eks"
#   public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDxjzfWw0Nz+AoER7s6SylTiDoB9u5LqNlDHCCEft5tSrjtMfsuSGp4G7x4xOJgGakvbfo753hmTYeXBtFO3xXiv6M3V7qbJye9W/eJl7IvewTE7/LgwSIEIOIUDgtKcsyZ9N02brR3374Js+4Oh5w/EZ57Hayomt+WKZ4hM45MzuKHokJP3BiYsWPwDJc/o8fjXF4Sny8XVLJ81AUBP2W1Of1zRwJuVvSyT1zOibFkkgn07CeQoKqCcDOuRMFZgZ0TfGw7R18eONgCOeaKtVhD3Zpgw7R5F7jC5QMjAFTaB5NAOmMFfITW/thKBXCq+8gCbioNdebqY8OSG51pS92W7PqwbVmQYsPZiO4Z/ZhLqex+I4uxtcTm5PSmMf6S9Ct50OF26XlnQwK+aF4c455uHWorlrzDWcpeotJ9He+6LxwlhcwWvUTnwToUGhaqKYjY3CVIl9NQat8/TPKh60cCR5m4M632aeUymLzGMfUTrF2hAqDtRtysBqJmEX8EnIM= opstree@opstree-Latitude-3410"
# }

# resource "aws_launch_template" "eks_node_with_keypair" {

#   # instance_type is a required field so we need a default value.
#   # t3.medium is the default value when creating a node group in the AWS Console, use that.
#   instance_type = "t3.medium"

#   key_name = aws_key_pair.eks_key.key_name
# }