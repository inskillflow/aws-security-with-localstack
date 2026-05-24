# Solution — TP 4 (VPC + Security Groups + NACL)

Solution exécutable correspondant à [`../../04b-Chapitre4-Pratique-vpc-sg-nacl-iac.md`](../../04b-Chapitre4-Pratique-vpc-sg-nacl-iac.md).

> **Mock vs réel — réseau :** LocalStack accepte la création des VPC, subnets, SG, NACL, mais **n'effectue aucun filtrage réseau**. Ce TP enseigne la **syntaxe IaC** et la **conception**.

---

## Contenu

| Fichier | Rôle |
|---|---|
| `docker-compose.yml` | LocalStack + tools |
| `Dockerfile.tools` | Image avec Terraform, AWS CLI, boto3 |
| `terraform/main.tf` | VPC, subnets, IGW, route tables, SG, NACL |
| `terraform/variables.tf` | CIDR, AZ |
| `terraform/outputs.tf` | IDs des ressources |

## Démarrage rapide

```bash
cp .env.example .env
docker compose build
docker compose up -d localstack tools

docker compose run --rm tools terraform -chdir=terraform init
docker compose run --rm tools terraform -chdir=terraform apply -auto-approve
```

## Validations

```bash
docker compose run --rm tools aws --endpoint-url=http://localstack:4566 ec2 describe-vpcs
docker compose run --rm tools aws --endpoint-url=http://localstack:4566 ec2 describe-subnets
docker compose run --rm tools aws --endpoint-url=http://localstack:4566 ec2 describe-security-groups
docker compose run --rm tools aws --endpoint-url=http://localstack:4566 ec2 describe-network-acls
```

## Nettoyage

```bash
docker compose run --rm tools terraform -chdir=terraform destroy -auto-approve
docker compose down -v
```
