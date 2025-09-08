output "athena_reader_access_key_id" {
  value = aws_iam_access_key.athena_reader_key.id
}

output "athena_reader_secret_access_key" {
  value     = aws_iam_access_key.athena_reader_key.secret
  sensitive = true
}
