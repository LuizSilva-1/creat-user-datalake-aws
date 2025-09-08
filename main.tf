###############################################################
# CONFIGURAÇÃO DO TERRAFORM E PROVIDER
###############################################################
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

###############################################################
# DATA SOURCES
###############################################################
data "aws_caller_identity" "current" {}

###############################################################
# GRUPO GLOBAL IAM (somente criado uma vez)
###############################################################
resource "aws_iam_group" "athena_group" {
  name = "athena-datalake-base-group"
}

# Política padrão do grupo (apenas 1 vez, aplicada a todos os clientes)
resource "aws_iam_policy" "athena_group_policy" {
  name   = "permissoesAthenaGrupoBase"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AthenaListAndRun"
        Effect = "Allow"
        Action = [
          "athena:ListApplicationDPUSizes",
          "athena:ListEngineVersions",
          "athena:ListDataCatalogs",
          "athena:GetNamespace",
          "athena:GetQueryExecutions",
          "athena:ListWorkGroups",
          "athena:GetCatalogs",
          "athena:ListCapacityReservations",
          "athena:GetNamespaces",
          "athena:GetExecutionEngine",
          "athena:GetExecutionEngines",
          "athena:GetTables",
          "athena:GetTable",
          "athena:ListExecutors",
          "athena:RunQuery"
        ]
        Resource = "*"
      },
      {
        Sid    = "AthenaSpecificResources"
        Effect = "Allow"
        Action = "athena:*"
        Resource = [
          "arn:aws:athena:*:${data.aws_caller_identity.current.account_id}:workgroup/*",
          "arn:aws:athena:*:${data.aws_caller_identity.current.account_id}:capacity-reservation/*",
          "arn:aws:athena:*:${data.aws_caller_identity.current.account_id}:datacatalog/*"
        ]
      }
    ]
  })
}

# Garante que a política do grupo só é criada/atualizada uma vez
resource "aws_iam_group_policy_attachment" "athena_group_attach" {
  group      = aws_iam_group.athena_group.name
  policy_arn = aws_iam_policy.athena_group_policy.arn
}

###############################################################
# MÓDULOS DE CLIENTES
###############################################################
module "cliente_luiz" {
  source            = "./modules/cliente_datalake"
  nome_do_cliente   = "luiz-aws"
  bucket_resultados = "meu-bucket"
  grupo_iam         = aws_iam_group.athena_group.name
  region            = var.region
}

module "cliente_devops" {
  source            = "./modules/cliente_datalake"
  nome_do_cliente   = "devops-luiz"
  bucket_resultados = "meu-bucket"
  grupo_iam         = aws_iam_group.athena_group.name
  region            = var.region
}

