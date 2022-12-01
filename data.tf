data "aws_eks_cluster_auth" "this" {
  name = module.eks.eks_cluster_id
}

data "aws_acm_certificate" "issued" {
  domain   = var.eks_cluster_domain
  statuses = ["ISSUED"]
}

data "aws_availability_zones" "available" {}

data "aws_iam_policy_document" "mng_assume_role_policy" {
  statement {
    sid = "EKSWorkerAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
