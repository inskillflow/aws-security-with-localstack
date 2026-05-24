# Solution — TP 5 (S3 hardening + KMS)

Solution exécutable correspondant à [`../../05b-Chapitre5-Pratique-s3-hardening-kms.md`](../../05b-Chapitre5-Pratique-s3-hardening-kms.md).

> **Mock vs réel — S3/KMS :** S3 (versioning, public access block, SSE-KMS, bucket policy) et KMS (encrypt/decrypt, GenerateDataKey) sont bien émulés par LocalStack. La rotation automatique des clés et certains événements CloudTrail-KMS sont limités.

---

## Contenu

| Fichier | Rôle |
|---|---|
| `docker-compose.yml` | LocalStack + tools |
| `Dockerfile.tools` | Terraform, AWS CLI, boto3 |
| `terraform/main.tf` | KMS, bucket data, bucket logs |
| `terraform/variables.tf` | Noms et préfixes |
| `terraform/outputs.tf` | ARNs et IDs |

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
docker compose run --rm tools aws --endpoint-url=http://localstack:4566 s3api get-bucket-versioning --bucket secdemo-data-bucket
docker compose run --rm tools aws --endpoint-url=http://localstack:4566 s3api get-public-access-block --bucket secdemo-data-bucket
docker compose run --rm tools aws --endpoint-url=http://localstack:4566 s3api get-bucket-encryption --bucket secdemo-data-bucket
docker compose run --rm tools aws --endpoint-url=http://localstack:4566 s3api get-bucket-policy --bucket secdemo-data-bucket
docker compose run --rm tools aws --endpoint-url=http://localstack:4566 s3api get-bucket-logging --bucket secdemo-data-bucket
docker compose run --rm tools aws --endpoint-url=http://localstack:4566 kms list-aliases
```

## Test d'envelope encryption (boto3)

Un petit script Python pour générer une data key, chiffrer puis déchiffrer :

```bash
docker compose run --rm tools python -c "
import boto3, os, base64
kms = boto3.client('kms', endpoint_url=os.environ['LOCALSTACK_ENDPOINT'])
alias = 'alias/secdemo-data'
resp = kms.generate_data_key(KeyId=alias, KeySpec='AES_256')
print('CiphertextBlob (b64):', base64.b64encode(resp['CiphertextBlob']).decode())
dec = kms.decrypt(CiphertextBlob=resp['CiphertextBlob'])
print('Plaintext matches:', dec['Plaintext'] == resp['Plaintext'])
"
```

## Nettoyage

```bash
docker compose run --rm tools terraform -chdir=terraform destroy -auto-approve
docker compose down -v
```
