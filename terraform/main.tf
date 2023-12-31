# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.77.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Main resource group
resource "azurerm_resource_group" "rg_arg" {
  name     = var.resource_group
  location = var.location
  tags = {
    environment = "Terraform Lab"
  }
}

resource "azurerm_public_ip" "ip" {
  name                = var.public_ip_name
  resource_group_name = azurerm_resource_group.rg_main.name
  location            = azurerm_resource_group.rg_main.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}
data "azurerm_public_ip" "ip" {
  name                = azurerm_public_ip.ip.name
  resource_group_name = azurerm_resource_group.rg_main.name
}
# Registre de conteneur (container registry)
resource "azurerm_container_registry" "rg_container_registry" {
  name                = "acrelo"
  resource_group_name = azurerm_resource_group.rg_arg.name
  location            = azurerm_resource_group.rg_arg.location
  sku                 = "Standard"
}

# Cluster Kubernetes (kubernetes cluster)
resource "azurerm_kubernetes_cluster" "rg_kubernetes_cluster" {
  name                = "kubernetesCluster"
  resource_group_name = azurerm_resource_group.rg_arg.name
  location            = azurerm_resource_group.rg_arg.location
  dns_prefix          = "kubernetesCluster"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

resource "azurerm_role_assignment" "rg_acr_pull" {
  depends_on = [azurerm_kubernetes_cluster.rg_kubernetes_cluster]
  principal_id                     = azurerm_kubernetes_cluster.rg_kubernetes_cluster.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.rg_container_registry.id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "acr_Push" {
  principal_id         = data.azurerm_client_config.current.object_id
  role_definition_name = "AcrPush"
  scope                = azurerm_container_registry.rg_container_registry.id
}

# output "client_object_id" {
#   value = data.azurerm_client_config.current.object_id
# }

data "azurerm_client_config" "current" {}

resource "azurerm_public_ip" "rg_public_ip" {
  name                = "publicIp1"
  resource_group_name = azurerm_resource_group.rg_arg.name
  location            = azurerm_resource_group.rg_arg.location
  allocation_method   = "Static"

  tags = {
    environment = "Terraform Lab"
  }
}

output "instance_public_ip" {
   description = "Public IP"
   value       = azurerm_public_ip.rg_public_ip.public_ip_prefix_id
}

# Storage account
module "storage_account" {
  source         = "./modules/storage_account"
  acccount_name  = var.storage_account_name
  resource_group = azurerm_resource_group.rg_arg
  container_envs = ["dev", "test", "prod"]
  tags = {
    environment = "Terraform Lab"
  }
}
