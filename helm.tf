resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "actions-runner-system"
  }

  depends_on = [
    module.eks,
    time_sleep.wait_60_seconds_after_eks_blueprints
  ]
}

resource "kubernetes_secret" "secret" {
  metadata {
    name      = "controller-manager"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }

  data = {
    "github_app_id"              = var.github_app_id
    "github_app_installation_id" = var.github_app_installation_id
    "github_app_private_key"     = file(var.github_private_key_file_path)
  }
}

resource "helm_release" "arc" {
  name            = "actions-runner-controller"
  repository      = "https://actions-runner-controller.github.io/actions-runner-controller"
  chart           = "actions-runner-controller"
  version         = "0.21.1"
  namespace       = kubernetes_namespace.namespace.metadata[0].name
  force_update    = true
  recreate_pods   = true
  cleanup_on_fail = true
  wait_for_jobs   = true

  values = [
    file("values.yaml")
  ]

  depends_on = [
    time_sleep.wait_60_seconds_after_eks_addons,
    kubernetes_secret.secret
  ]
}

resource "helm_release" "runner_set" {
  chart           = "${path.module}/runnerset"
  name            = "github-actions"
  namespace       = kubernetes_namespace.namespace.metadata[0].name
  force_update    = true
  recreate_pods   = true
  cleanup_on_fail = true
  wait_for_jobs   = true

  depends_on = [
    helm_release.arc,
    kubernetes_service_account.runner
  ]
}
