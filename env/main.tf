module "eks-vpc" {
  source              = "../modules/network/"
  vpc-name            = "eks-cluster-vpc"
  vpc-cidr-block      = "10.0.0.0/16"
  public-subnet-name  = "eks-pub-sub"
  private-subnet-name = "eks-pvt-sub"

  public-cidr  = ["10.0.1.0/24", "10.0.2.0/24"]
  private-cidr = ["10.0.3.0/24", "10.0.4.0/24"]
  igw-name     = "eks-igw"
  nat-name     = "eks-nat"


  pub-rt-name = "eks-pub-rt"
  pvt-rt-name = "eks-pvt-rt"
  azs         = ["ap-south-1a", "ap-south-1b"]
  #cluster-name = "test-eks-cluster"

}

################ EKS Cluster ###############

module "demo-cluster" {
  source = "../modules/eks/"
  cluster-name = "test-eks-cluster"
  #vpc_id = data.aws_vpc.eks-vpc.id
  vpc_id = module.eks-vpc.vpc_id
  public-subnet = module.eks-vpc.public_subnet_id
}


################# EKS Worker Node ############


module "worker-node" {
  source = "../modules/eks/workernode/"
  cluster-name = module.demo-cluster.cluster_name
  node-group-name = "demo-worker"
  public-subnet = module.eks-vpc.public_subnet_id
  instance-type = ["t2.large"]
  vpc-id = module.eks-vpc.vpc_id
  node-disk-size = 10
  capacity-type = "ON_DEMAND"
}


