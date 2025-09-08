# Módulo Terraform – Cliente DataLake 

Este módulo automatiza a criação de toda a estrutura necessária para conceder acesso a clientes no **Athena + Glue**, garantindo isolamento, segurança e padronização entre ambientes.

---

## 📖 Visão Geral

O objetivo é facilitar a criação de recursos AWS para cada cliente do **AWS**, evitando trabalho manual e erros de configuração.  
Com este módulo, basta informar o nome do cliente e o bucket de resultados, que todo o pacote de recursos será criado automaticamente.

---

## 🚀 Recursos Criados pelo Módulo

1. **Workgroup no Athena**
   - Cria um grupo exclusivo para o cliente (`wg-nome-do-cliente`).
   - Garante auditoria e rastreabilidade das queries executadas.
   - Configura a saída de resultados no bucket central de forma isolada.

2. **Diretório no S3**
   - Cria uma pasta no bucket central de resultados (`cliente=nome-do-cliente`).
   - Garante separação dos resultados de queries entre clientes.

3. **Database no Glue**
   - Cria um banco de dados lógico no Glue (`nome-do-cliente`).
   - Esse catálogo é usado pelo Athena para acessar tabelas.

4. **Política IAM**
   - Cria uma política (`politica-datalake-nome-do-cliente`).
   - Restringe acesso apenas ao bucket e database do cliente.
   - Impede acessos indevidos a dados de outros clientes.

5. **Usuário IAM**
   - Cria um usuário (`nome-do-cliente-athena-reader`).
   - Permite que o cliente acesse via CLI/API.

6. **Grupo IAM**
   - Cria (ou reutiliza) um grupo chamado `athena-datalake-base-group`.
   - Centraliza permissões para leitores do Athena.

7. **Associações**
   - Liga o usuário ao grupo e a política criada.

8. **Credenciais IAM**
   - Gera **Access Key** e **Secret Key** para uso em CLI/API.
   - ⚠️ O Secret só aparece no primeiro `terraform apply`.

---

## 📂 Estrutura do Projeto

```
terraform/
├── main.tf              # Exemplo de uso do módulo
├── variables.tf         # Variáveis globais
├── outputs.tf           # Saídas globais
└── modules/
    └── cliente_datalake/
        ├── main.tf      # Recursos do módulo (Athena, S3, Glue, IAM)
        ├── variables.tf # Variáveis do módulo
        └── outputs.tf   # Saídas do módulo
```

---

## ⚙️ Variáveis do Módulo

| Variável          | Descrição | Tipo | Exemplo |
|-------------------|-----------|------|---------|
| `nome_do_cliente` | Nome do cliente (em minúsculas, sem espaços) | string | `"luiz-aws"` |
| `bucket_resultados` | Bucket central para salvar resultados do Athena | string | `"bucketluiz"` |

---

## 📌 Exemplo de Uso

```hcl
provider "aws" {
  region = "us-east-1"
}

module "cliente_luiz" {
  source            = "./modules/cliente_datalake"
  nome_do_cliente   = "luiz-aws"
  bucket_resultados = "bucketluiz"
}
```

---

## ▶️ Como Executar

1. Inicializar o Terraform:
   ```bash
   terraform init
   ```

2. Visualizar o plano de execução:
   ```bash
   terraform plan
   ```

3. Aplicar as mudanças:
   ```bash
   terraform apply
   ```

4. Exibir as credenciais geradas:
   ```bash
   terraform output
   ```

⚠️ **Importante**:  
- Salve a **Secret Key** em local seguro.  
- Ela não será exibida novamente após o primeiro apply.  

---

## 🔒 Boas Práticas de Segurança

- Nunca envie credenciais IAM por e-mail ou mensagens abertas.  
- Utilize um **cofre de senhas** (ex.: AWS Secrets Manager, Vault, Bitwarden).  
- Revogue chaves antigas quando gerar novas.  
- Monitore o uso via **CloudTrail**.  

---

## 📊 Monitoramento e Auditoria

- O Workgroup publica métricas no **CloudWatch**, permitindo monitorar consultas.  
- As tags `CLIENTE=nome-do-cliente` ajudam na auditoria e relatórios de custo no **Cost Explorer**.  

---

## ✅ Checklist antes do Deploy

- [ ] Confirmar que o bucket central de resultados já existe.  
- [ ] Verificar se o nome do cliente está em letras minúsculas.  
- [ ] Garantir que não há duplicidade de usuário/política para o mesmo cliente.  
- [ ] Executar `terraform plan` antes de `apply`.  

---

## 👨‍💻 Autor / Manutenção

- **Luiz Silva**  
---
