resource "aws_iam_role" "mng" {
  name                  = "github-runner-mng-role"
  description           = "EKS Managed Node group IAM Role"
  assume_role_policy    = data.aws_iam_policy_document.mng_assume_role_policy.json
  path                  = "/"
  force_detach_policies = true

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}

resource "aws_iam_instance_profile" "mng" {
  name = "github-runner-mng-profile"
  role = aws_iam_role.mng.name
  path = "/"

  lifecycle {
    create_before_destroy = true
  }
}
