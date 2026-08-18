# STEP 2b: EKS cluster + managed node group.
# This is what Kubernetes manifests / Helm charts get deployed to later.

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${var.project_name}-eks"
  cluster_version = "1.31"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access = true

  eks_managed_node_groups = {
    default = {
      min_size       = 2
      max_size       = 4
      desired_size   = 2
      instance_types = ["t3.small"]
    }
  }

  # Lets the EC2 CI/CD box (Jenkins) run kubectl/helm against this cluster
  enable_cluster_creator_admin_permissions = true
}
