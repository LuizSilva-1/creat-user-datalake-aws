variable "nome_do_cliente" {
  description = "Nome do cliente (usar minúsculas e sem espaços)"
  type        = string
}

variable "bucket_resultados" {
  description = "Bucket onde ficam armazenados os resultados do Athena"
  type        = string
}

variable "grupo_iam" {
  description = "Nome do grupo IAM existente para associar o usuário"
  type        = string
}

variable "region" {
  description = "Região da AWS"
  type        = string
}
