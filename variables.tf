variable "region" {
  type = string
}

variable "profile" {
  type    = string
  default = null
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "eks_cluster_domain" {
  type = string
}

variable "route53_zone_arns" {
  type = list(string)
}

variable "github_app_id" {
  type      = string
  sensitive = true
}

variable "github_private_key_file_path" {
  type      = string
  sensitive = true
}

variable "github_app_installation_id" {
  type      = string
  sensitive = true
}
