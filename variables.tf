output "luiz_athena_reader_access_key_id" {
  value = module.cliente_luiz.athena_reader_access_key_id
}

output "luiz_athena_reader_secret_access_key" {
  value     = module.cliente_luiz.athena_reader_secret_access_key
  sensitive = true
}

output "devops_athena_reader_access_key_id" {
  value = module.cliente_devops.athena_reader_access_key_id
}

output "devops_athena_reader_secret_access_key" {
  value     = module.cliente_devops.athena_reader_secret_access_key
  sensitive = true
}

variable "region" {
  description = "Região da AWS"
  type        = string
  default     = "us-east-1"
}
