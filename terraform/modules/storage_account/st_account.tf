
# Storage Account
resource "azurerm_storage_account" "st_account" {
  name                     = var.acccount_name
  resource_group_name      = var.resource_group.name
  location                 = var.resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.tags
}

# Containers (for each environment)
resource "azurerm_storage_container" "st_container" {
  name                  = var.container_envs[count.index]
  count                 = length(var.container_envs)
  storage_account_name  = azurerm_storage_account.st_account.name
  container_access_type = "private"
}


