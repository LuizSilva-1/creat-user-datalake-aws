###############################################################
# Módulo: cliente_datalake
###############################################################

# Workgroup no Athena
resource "aws_athena_workgroup" "cliente" {
  name = "wg-${var.nome_do_cliente}"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${var.bucket_resultados}/cliente=${var.nome_do_cliente}/"
    }
  }

  tags = {
    CLIENTE = var.nome_do_cliente
  }
}

# Database no Glue
resource "aws_glue_catalog_database" "cliente" {
  name = var.nome_do_cliente
}

# Política IAM específica do cliente (somente leitura)
data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "datalake" {
  name   = "politica-datalake-${var.nome_do_cliente}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Permissões de leitura no S3
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucketMultipartUploads",
          "s3:ListBucket",
          "s3:ListMultipartUploadParts",
          "s3:GetObject",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "arn:aws:s3:::${var.bucket_resultados}",
          "arn:aws:s3:::${var.bucket_resultados}/cliente=${var.nome_do_cliente}/*"
        ]
      },
      # Permissões de leitura no Glue Catalog
      {
        Effect = "Allow"
        Action = [
          "glue:SearchTables",
          "glue:GetTables",
          "glue:GetPartitions",
          "glue:BatchGetPartition",
          "glue:GetDatabases",
          "glue:GetPartitionIndexes",
          "glue:GetTable",
          "glue:GetDatabase",
          "glue:GetPartition"
        ]
        Resource = [
          "arn:aws:glue:${var.region}:${data.aws_caller_identity.current.account_id}:catalog",
          aws_glue_catalog_database.cliente.arn,
          "${aws_glue_catalog_database.cliente.arn}/*"
        ]
      }
    ]
  })
}

# Usuário IAM do cliente
resource "aws_iam_user" "athena_reader" {
  name = "${var.nome_do_cliente}-athena-reader"
  tags = {
    CLIENTE = var.nome_do_cliente
  }
}

# Associação da política ao grupo
resource "aws_iam_user_group_membership" "membership" {
  user   = aws_iam_user.athena_reader.name
  groups = [var.grupo_iam]
}

# Anexa política específica diretamente ao usuário
resource "aws_iam_user_policy_attachment" "user_attach" {
  user       = aws_iam_user.athena_reader.name
  policy_arn = aws_iam_policy.datalake.arn
}

# Chaves de acesso IAM
resource "aws_iam_access_key" "athena_reader_key" {
  user = aws_iam_user.athena_reader.name
}
