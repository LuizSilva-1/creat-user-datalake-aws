# Comentários Explicativos – Módulo Cliente DataLake

Este documento descreve em detalhes o que cada recurso Terraform está fazendo dentro do módulo `cliente_datalake`.

---

## Workgroup no Athena (`aws_athena_workgroup`)
- Cria um **grupo de trabalho** exclusivo para o cliente (`wg-nome-do-cliente`).
- **enforce_workgroup_configuration = true**  
  Garante que o cliente não pode alterar a configuração do Workgroup.  
- **publish_cloudwatch_metrics_enabled = true**  
  Habilita métricas no CloudWatch, permitindo monitorar consultas.  
- **result_configuration.output_location**  
  Define o bucket/pasta onde os resultados do Athena serão salvos.  

---

## Diretório no S3 (`aws_s3_object`)
- Cria a pasta `cliente=nome-do-cliente/` dentro do bucket central.
- Essa pasta serve como **output location** dos resultados do Athena.

---

## Database no Glue (`aws_glue_catalog_database`)
- Cria um database com o nome do cliente em minúsculas.  
- Esse catálogo será usado para registrar tabelas acessíveis pelo Athena.  

---

## Política IAM (`aws_iam_policy`)
- Cria uma política restrita ao cliente.  
- Permite apenas:  
  - `s3:GetObject` e `s3:ListBucket` no bucket/pasta dele.  
  - `glue:GetDatabase` e `glue:GetTables` apenas no database do cliente.  

---

## Usuário IAM (`aws_iam_user`)
- Cria um usuário chamado `nome-do-cliente-athena-reader`.  
- Esse usuário terá credenciais (Access Key + Secret Key) para CLI/API.  

---

## Grupo IAM (`aws_iam_group`)
- Grupo chamado `athena-datalake-base-group`.  
- Facilita a padronização, pois todos os usuários leitores ficam no mesmo grupo.  

---

## Associação de Política ao Grupo (`aws_iam_group_policy_attachment`)
- Liga a política criada ao grupo do Athena.  
- Assim, qualquer usuário dentro do grupo herda as permissões.  

---

## Associação de Usuário ao Grupo (`aws_iam_user_group_membership`)
- Coloca o usuário dentro do grupo criado.  
- Isso faz com que ele receba as permissões.  

---

## Chaves de Acesso (`aws_iam_access_key`)
- Gera **Access Key ID** e **Secret Access Key**.  
- Essas credenciais são entregues ao cliente para acessar o Athena via CLI ou ferramenta de query.  

⚠️ **Importante**:  
- O Secret só é exibido uma vez, no primeiro `terraform apply`.  
- Deve ser salvo em um cofre de senhas.  

---

## Saídas (`output`)
- `athena_reader_access_key_id` → exibe a chave pública.  
- `athena_reader_secret_access_key` → exibe a chave secreta (sensível).  
