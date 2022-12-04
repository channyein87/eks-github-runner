module "eks" {
  source = "git@github.com:aws-ia/terraform-aws-eks-blueprints.git?ref=v4.17.0"

  cluster_name       = "github-runner-cluster"
  cluster_version    = "1.23"
  vpc_id             = var.vpc_id
  private_subnet_ids = var.private_subnet_ids

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
    ingress_cluster_to_node_all_traffic = {
      description                   = "Cluster API to Nodegroup all traffic"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }

  managed_node_groups = {
    mg5 = {
      node_group_name = "mg5"
      instance_types  = ["m5.large"]
      max_size        = 3
      desired_size    = 1
      min_size        = 1
      create_iam_role = false
      iam_role_arn    = aws_iam_role.mng.arn
      subnet_ids      = var.private_subnet_ids
    }
  }
}

resource "time_sleep" "wait_60_seconds_after_eks_blueprints" {
  depends_on      = [module.eks]
  create_duration = "60s"
}

resource "aws_ec2_tag" "public_subnets_cluster" {
  for_each = toset(var.public_subnet_ids)

  key         = "kubernetes.io/cluster/github-runner-cluster"
  resource_id = each.value
  value       = "shared"
}

resource "aws_ec2_tag" "public_subnets_elb" {
  for_each = toset(var.public_subnet_ids)

  key         = "kubernetes.io/role/elb"
  resource_id = each.value
  value       = "1"
}

resource "aws_ec2_tag" "private_subnets_cluster" {
  for_each = toset(var.private_subnet_ids)

  key         = "kubernetes.io/cluster/inv-np-dev-1"
  resource_id = each.value
  value       = "shared"
}

resource "aws_ec2_tag" "private_subnets_elb" {
  for_each = toset(var.private_subnet_ids)

  key         = "kubernetes.io/role/internal-elb"
  resource_id = each.value
  value       = "1"
}
