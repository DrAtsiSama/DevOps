# Resource Group
variable "acccount_name" {}
variable "resource_group" {}
variable "tags" {}
variable "container_envs" {
  description = "Create One container per environment"
  type        = list(string)
}
