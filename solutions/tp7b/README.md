# Solution — TP 7 (Auto-remédiation S3 via Lambda + EventBridge)

Solution exécutable correspondant à [`../../07b-Chapitre7-Pratique-lambda-eventbridge-auto-remediation.md`](../../07b-Chapitre7-Pratique-lambda-eventbridge-auto-remediation.md).

> **Mock vs réel — Lambda + EventBridge :** Lambda et EventBridge fonctionnent bien dans LocalStack. La propagation **CloudTrail → EventBridge** est partielle, donc on **invoque la Lambda manuellement** avec un payload de test représentatif de l'événement CloudTrail réel.

---

## Contenu

| Fichier | Rôle |
|---|---|
| `docker-compose.yml` | LocalStack + tools (avec `LAMBDA_EXECUTOR=docker`) |
| `Dockerfile.tools` | Terraform, AWS CLI, boto3, zip |
| `lambda/handler.py` | Handler Python d'auto-remédiation |
| `terraform/main.tf` | Lambda, rôle IAM, règle EventBridge |
| `terraform/variables.tf` | Préfixe et runtime |
| `terraform/outputs.tf` | ARNs |

## Démarrage rapide

```bash
cp .env.example .env
docker compose build
docker compose up -d localstack tools

docker compose run --rm tools terraform -chdir=terraform init
docker compose run --rm tools terraform -chdir=terraform apply -auto-approve
```

## Tester la remédiation (invocation manuelle)

```bash
# Creer un bucket public (case typique a remedier)
docker compose run --rm tools aws --endpoint-url=http://localstack:4566 s3 mb s3://test-public-bucket

# Verifier qu'il n'a PAS de public access block
docker compose run --rm tools aws --endpoint-url=http://localstack:4566 s3api get-public-access-block --bucket test-public-bucket || echo 'pas de block'

# Invoquer la Lambda avec un payload EventBridge simule
docker compose run --rm tools bash -lc '
cat > /tmp/event.json <<EOF
{
  "source": "aws.s3",
  "detail-type": "AWS API Call via CloudTrail",
  "detail": {
    "eventName": "CreateBucket",
    "requestParameters": { "bucketName": "test-public-bucket" }
  }
}
EOF
aws --endpoint-url=http://localstack:4566 lambda invoke \
  --function-name secdemo-s3-remediation \
  --payload file:///tmp/event.json /tmp/out.json
cat /tmp/out.json
'

# Verifier que le block est maintenant en place
docker compose run --rm tools aws --endpoint-url=http://localstack:4566 s3api get-public-access-block --bucket test-public-bucket
```

## Inspecter les logs de la Lambda

```bash
docker compose run --rm tools aws --endpoint-url=http://localstack:4566 logs describe-log-groups --log-group-name-prefix /aws/lambda/secdemo-s3-remediation
```

## Nettoyage

```bash
docker compose run --rm tools terraform -chdir=terraform destroy -auto-approve
docker compose down -v
```
