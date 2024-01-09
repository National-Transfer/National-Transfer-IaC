resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "5.52.0"
  namespace        = "argocd"
  create_namespace = true

  values = [file("${path.module}/argo-cd-values.yml")]

}


resource "terraform_data" "argocd-password" {
  triggers_replace = [
    helm_release.argocd.id
  ]
  provisioner "local-exec" {
    command = <<EOT
        az aks get-credentials --resource-group ${azurerm_resource_group.this.name} --name ${azurerm_kubernetes_cluster.this.name} --overwrite-existing && mkdir -p secrets && kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath={.data.password} | base64 -d > secrets/argocd-login.txt
    EOT
    
  }
}

resource "terraform_data" "argocd-delete-sercret" {
  triggers_replace = [
    terraform_data.argocd-password
  ]

  provisioner "local-exec" {
    command = <<EOT
    az aks get-credentials --resource-group ${azurerm_resource_group.this.name} --name ${azurerm_kubernetes_cluster.this.name} --overwrite-existing && kubectl -n argocd delete secret argocd-initial-admin-secret
    EOT
  }
}

data "kubectl_filename_list" "manifests" {
  pattern = "./argocd_manifests/*.yml"
}

resource "kubectl_manifest" "test" {
  count     = length(data.kubectl_filename_list.manifests.matches)
  yaml_body = file(element(data.kubectl_filename_list.manifests.matches, count.index))

  depends_on = [helm_release.argocd]
}

