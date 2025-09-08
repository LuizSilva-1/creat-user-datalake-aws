output "athena_reader_access_key_id" {
  value = module.cliente_luiz.athena_reader_access_key_id
}

output "athena_reader_secret_access_key" {
  value     = module.cliente_luiz.athena_reader_secret_access_key
  sensitive = true
}
