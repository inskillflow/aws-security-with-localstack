# Solution — TP 6 (CloudWatch Logs + Metric Filter + Alarm)

Solution exécutable correspondant à [`../../06b-Chapitre6-Pratique-cloudwatch-logs-alarms.md`](../../06b-Chapitre6-Pratique-cloudwatch-logs-alarms.md).

> **Mock vs réel — observabilité :** CloudWatch Logs / Metric Filters / Alarms fonctionnent bien dans LocalStack. SNS reçoit l'événement d'alarme mais ne déclenche pas d'envoi réel.

---

## Contenu

| Fichier | Rôle |
|---|---|
| `docker-compose.yml` | LocalStack + tools |
| `Dockerfile.tools` | Terraform, AWS CLI, boto3 |
| `terraform/main.tf` | Log group, metric filters, alarm, topic SNS |
| `terraform/variables.tf` | Rétention, seuils |
| `terraform/outputs.tf` | Noms / ARNs |

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
docker compose run --rm tools aws --endpoint-url=http://localstack:4566 logs describe-log-groups
docker compose run --rm tools aws --endpoint-url=http://localstack:4566 logs describe-metric-filters --log-group-name /secdemo/app
docker compose run --rm tools aws --endpoint-url=http://localstack:4566 cloudwatch describe-alarms
docker compose run --rm tools aws --endpoint-url=http://localstack:4566 sns list-topics
```

## Tester l'alarme : injecter des logs `Unauthorized`

```bash
docker compose run --rm tools bash -lc "
LSE=http://localstack:4566
LG=/secdemo/app
LS=stream1
aws --endpoint-url=\$LSE logs create-log-stream --log-group-name \$LG --log-stream-name \$LS || true
TS=\$(date +%s)000
EVENTS=\$(jq -n --arg ts \$TS '[
  {timestamp: (\$ts|tonumber), message: \"Unauthorized access from 1.2.3.4\"},
  {timestamp: (\$ts|tonumber), message: \"Unauthorized access from 1.2.3.4\"},
  {timestamp: (\$ts|tonumber), message: \"Unauthorized access from 1.2.3.4\"},
  {timestamp: (\$ts|tonumber), message: \"Unauthorized access from 1.2.3.4\"},
  {timestamp: (\$ts|tonumber), message: \"Unauthorized access from 1.2.3.4\"},
  {timestamp: (\$ts|tonumber), message: \"Unauthorized access from 1.2.3.4\"}
]')
aws --endpoint-url=\$LSE logs put-log-events --log-group-name \$LG --log-stream-name \$LS --log-events \"\$EVENTS\"
"
```

Puis vérifier l'état de l'alarme :

```bash
docker compose run --rm tools aws --endpoint-url=http://localstack:4566 cloudwatch describe-alarms --alarm-names secdemo-too-many-unauthorized
```

## Nettoyage

```bash
docker compose run --rm tools terraform -chdir=terraform destroy -auto-approve
docker compose down -v
```
