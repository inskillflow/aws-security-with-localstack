# Solution — TP 3 (IAM users, groups, roles, policies)

Solution exécutable correspondant au document [`../../03b-Chapitre3-Pratique-iam-users-groups-roles-policies.md`](../../03b-Chapitre3-Pratique-iam-users-groups-roles-policies.md).

> **Mock vs réel — IAM enforcement :** LocalStack **n'applique pas** les policies IAM en mode par défaut. Les ressources sont créées et les ARNs sont valides, mais aucun `Allow`/`Deny` n'est vraiment évalué. Ce TP enseigne la **syntaxe** et la **logique**.

---

## Contenu

| Fichier | Rôle |
|---|---|
| `docker-compose.yml` | LocalStack + conteneur `tools` |
| `Dockerfile.tools` | Image avec Terraform, AWS CLI, boto3 |
| `.env.example` | Variables d'environnement (token LocalStack) |
| `.gitignore` | Exclut `.env`, `volume/`, état Terraform |
| `terraform/provider.tf` | Provider AWS vers `http://localstack:4566` |
| `terraform/main.tf` | Users, groups, policies, role Lambda |
| `terraform/variables.tf` | Variables (nom du projet, bucket cible) |
| `terraform/outputs.tf` | ARNs exposés |

## Démarrage rapide

```bash
cp .env.example .env
# Editer .env et coller votre LOCALSTACK_AUTH_TOKEN

docker compose build
docker compose up -d localstack tools

docker compose run --rm tools terraform -chdir=terraform init
docker compose run --rm tools terraform -chdir=terraform plan
docker compose run --rm tools terraform -chdir=terraform apply -auto-approve
```

## Validations

```bash
docker compose run --rm tools aws --endpoint-url=http://localstack:4566 iam list-users
docker compose run --rm tools aws --endpoint-url=http://localstack:4566 iam list-groups
docker compose run --rm tools aws --endpoint-url=http://localstack:4566 iam list-policies --scope Local
docker compose run --rm tools aws --endpoint-url=http://localstack:4566 iam list-roles
```

## Nettoyage

```bash
docker compose run --rm tools terraform -chdir=terraform destroy -auto-approve
docker compose down -v
```
