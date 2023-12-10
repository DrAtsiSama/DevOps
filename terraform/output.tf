output "public_ip_address" {
   description = "IP adresses "
  value = data.azurerm_public_ip.ip.ip_address
}