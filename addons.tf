module "addons" {
  source = "git@github.com:aws-ia/terraform-aws-eks-blueprints.git//modules/kubernetes-addons?ref=v4.17.0"

  eks_cluster_id       = module.eks.eks_cluster_id
  eks_cluster_endpoint = module.eks.eks_cluster_endpoint
  eks_oidc_provider    = module.eks.oidc_provider
  eks_cluster_version  = module.eks.eks_cluster_version
  eks_cluster_domain   = var.eks_cluster_domain

  enable_metrics_server                = true
  enable_cluster_autoscaler            = true
  enable_cert_manager                  = true
  enable_aws_load_balancer_controller  = true
  enable_amazon_eks_aws_ebs_csi_driver = true
  enable_external_dns                  = true
  external_dns_route53_zone_arns       = var.route53_zone_arns

  depends_on = [
    time_sleep.wait_60_seconds_after_eks_blueprints
  ]
}

resource "time_sleep" "wait_60_seconds_after_eks_addons" {
  depends_on       = [module.addons]
  create_duration  = "60s"
  destroy_duration = "60s"
}
