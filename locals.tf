locals {
  env                 = "prod"
  region              = "eastus2"
  resource_group_name = "nt-transfer-rg"
  aks_name            = "nt-transfer-cluster"
  aks_version         = "1.27"
  acr_name            = "ntransferazurecontainerregistry"
}
