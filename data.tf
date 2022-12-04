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
    sid     = "EKSWorkerAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "runner_assume_role_policy" {
  statement {
    sid     = "RunnerAssumeRole"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [module.eks.eks_oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.eks_oidc_provider_arn, "/^(.*provider/)/", "")}:sub"
      values   = ["system:serviceaccount:actions-runner-system:actions-runner-iam-role"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.eks_oidc_provider_arn, "/^(.*provider/)/", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}
