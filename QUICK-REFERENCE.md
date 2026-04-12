# RSTUF Quick Reference Card

## Essential Commands

### Minikube
```bash
# Start
minikube start --driver=docker

# Status
minikube status

# Stop
minikube stop

# Delete
minikube delete

# Enable addons
minikube addons enable ingress
minikube addons enable ingress-dns

# Tunnel (keep running)
minikube tunnel
```

### Kubectl
```bash
# Get pods
kubectl get pods -n rstuf

# Watch pods
kubectl get pods -n rstuf --watch

# Logs
kubectl logs -n rstuf <pod-name>
kubectl logs -n rstuf -l app=rstuf-worker --tail=50

# Describe
kubectl describe pod -n rstuf <pod-name>

# Restart deployment
kubectl rollout restart deployment/rstuf-rstuf-worker -n rstuf

# Delete namespace
kubectl delete namespace rstuf
```

### Helm
```bash
# Add repo
helm repo add rstuf https://repository-service-tuf.github.io/helm-charts

# Update repos
helm repo update

# Search
helm search repo rstuf

# Install
helm upgrade --install rstuf rstuf/rstuf-demo -n rstuf --create-namespace

# Uninstall
helm uninstall rstuf -n rstuf

# List releases
helm list -n rstuf
```

### RSTUF CLI
```bash
# Install
pip install repository-service-tuf-cli

# Version
rstuf --version

# Ceremony
rstuf admin ceremony -b -u -f ceremony-payload.json

# Import artifacts
rstuf admin import-artifacts --csv artifacts.csv

# Metadata info
rstuf admin metadata info
```

### AWS CLI (LocalStack)
```bash
# Set environment
export AWS_ACCESS_KEY_ID=key
export AWS_SECRET_ACCESS_KEY=access
export AWS_DEFAULT_REGION=us-east-1
export AWS_ENDPOINT_URL=http://localstack.local

# List buckets
aws s3 ls

# List objects
aws s3 ls s3://tuf-metadata/
aws s3 ls s3://artifacts/ --recursive

# Upload file
aws s3 cp file.txt s3://artifacts/path/file.txt

# Download file
aws s3 cp s3://artifacts/path/file.txt ./
```

### RSTUF API
```bash
# Check status
curl http://rstuf.local/api/v1/

# Add artifact
curl -X POST http://rstuf.local/api/v1/artifacts \
  -H "Content-Type: application/json" \
  -d @payload.json

# Check task
curl "http://rstuf.local/api/v1/task?task_id=<TASK_ID>"

# List artifacts
curl http://rstuf.local/api/v1/artifacts

# Delete artifact
curl -X POST http://rstuf.local/api/v1/artifacts/delete \
  -H "Content-Type: application/json" \
  -d '{"artifacts": ["path/to/file"]}'
```

## Common Payloads

### Add Artifact
```json
{
  "artifacts": [
    {
      "path": "releases/app-v1.0.tar.gz",
      "info": {
        "length": 1024,
        "hashes": {
          "sha256": "abc123..."
        },
        "custom": {
          "version": "1.0.0"
        }
      }
    }
  ]
}
```

### Remove Artifact
```json
{
  "artifacts": ["releases/app-v1.0.tar.gz"]
}
```

### Ceremony Payload
```json
{
  "metadata": {
    "root": {
      "expiration": 365,
      "threshold": 1,
      "keys": 1
    },
    "targets": {
      "expiration": 365
    },
    "snapshot": {
      "expiration": 1
    },
    "timestamp": {
      "expiration": 1
    },
    "bins": {
      "number_of_delegated_bins": 256
    }
  }
}
```

## File Locations

### Local Machine
```
~/.rstuf/
  ├── keys/           # Generated keys
  ├── metadata/       # Local metadata cache
  └── config.yaml     # CLI configuration

/etc/hosts           # DNS configuration (Linux/Mac)
C:\Windows\System32\drivers\etc\hosts  # DNS (Windows)
```

### Kubernetes
```
Namespace: rstuf

Pods:
  - rstuf-rstuf-api-*
  - rstuf-rstuf-worker-*
  - rstuf-postgresql-0
  - rstuf-valkey-master-0
  - rstuf-localstack-*

Services:
  - rstuf-rstuf-api (http://rstuf.local)
  - rstuf-localstack (http://localstack.local)
```

### LocalStack S3
```
Buckets:
  - tuf-metadata/
      ├── 1.root.json
      ├── timestamp.json
      ├── snapshot.json
      ├── targets.json
      └── bins/
          ├── bin-0.json
          └── ...
  
  - artifacts/
      └── [your files]
```

## Troubleshooting Quick Checks

### 1. Is everything running?
```bash
minikube status
kubectl get pods -n rstuf
ps aux | grep "minikube tunnel"
```

### 2. Can I access services?
```bash
curl http://rstuf.local/api/v1/
curl http://localstack.local/
```

### 3. Are environment variables set?
```bash
env | grep AWS
```

### 4. Check logs
```bash
kubectl logs -n rstuf -l app=rstuf-api --tail=20
kubectl logs -n rstuf -l app=rstuf-worker --tail=20
```

### 5. Verify metadata
```bash
curl http://localstack.local/tuf-metadata/1.root.json
```

## Common Issues & Quick Fixes

| Issue | Quick Fix |
|-------|-----------|
| Cannot access rstuf.local | Check hosts file, verify tunnel is running |
| Pods not starting | Check Docker memory (4GB+), check logs |
| Task stuck in PENDING | Restart worker: `kubectl rollout restart deployment/rstuf-rstuf-worker -n rstuf` |
| S3 upload fails | Check AWS environment variables |
| Hash mismatch | Recalculate hash: `sha256sum file` |
| Ceremony fails | Verify API is accessible, check worker logs |

## Useful Aliases

Add to `.bashrc` or `.zshrc`:

```bash
# RSTUF shortcuts
alias rstuf-start='minikube start --driver=docker'
alias rstuf-stop='minikube stop'
alias rstuf-tunnel='minikube tunnel'
alias rstuf-pods='kubectl get pods -n rstuf'
alias rstuf-logs-api='kubectl logs -n rstuf -l app=rstuf-api --tail=50'
alias rstuf-logs-worker='kubectl logs -n rstuf -l app=rstuf-worker --tail=50'
alias rstuf-restart-worker='kubectl rollout restart deployment/rstuf-rstuf-worker -n rstuf'

# AWS LocalStack
alias aws-local='aws --endpoint-url http://localstack.local'

# RSTUF API
alias rstuf-api='curl http://rstuf.local/api/v1/'
alias rstuf-artifacts='curl http://rstuf.local/api/v1/artifacts'

# Environment setup
alias rstuf-env='export AWS_ACCESS_KEY_ID=key AWS_SECRET_ACCESS_KEY=access AWS_DEFAULT_REGION=us-east-1 AWS_ENDPOINT_URL=http://localstack.local'
```

## Helper Scripts

### Calculate Artifact Metadata
```bash
#!/bin/bash
# get-metadata.sh
FILE=$1
echo "Path: $FILE"
echo "Size: $(stat -c%s "$FILE" 2>/dev/null || stat -f%z "$FILE")"
echo "SHA256: $(sha256sum "$FILE" 2>/dev/null || shasum -a 256 "$FILE" | awk '{print $1}')"
```

### Check RSTUF Status
```bash
#!/bin/bash
# check-rstuf.sh
echo "Minikube: $(minikube status | grep -q Running && echo '✅' || echo '❌')"
echo "Pods: $(kubectl get pods -n rstuf --no-headers 2>/dev/null | grep -c '1/1.*Running')/$(kubectl get pods -n rstuf --no-headers 2>/dev/null | wc -l)"
echo "API: $(curl -s http://rstuf.local/api/v1/ > /dev/null && echo '✅' || echo '❌')"
echo "LocalStack: $(curl -s http://localstack.local/ > /dev/null && echo '✅' || echo '❌')"
```

### Register Artifact
```bash
#!/bin/bash
# register.sh
ARTIFACT=$1
PATH_IN_REPO=$2

HASH=$(sha256sum "$ARTIFACT" | awk '{print $1}')
SIZE=$(stat -c%s "$ARTIFACT")

aws s3 cp "$ARTIFACT" "s3://artifacts/$PATH_IN_REPO"

curl -X POST http://rstuf.local/api/v1/artifacts \
  -H "Content-Type: application/json" \
  -d "{\"artifacts\":[{\"path\":\"$PATH_IN_REPO\",\"info\":{\"length\":$SIZE,\"hashes\":{\"sha256\":\"$HASH\"}}}]}"
```

## Important URLs

- **RSTUF API**: http://rstuf.local/api/v1/
- **API Docs**: http://rstuf.local/docs
- **LocalStack**: http://localstack.local/
- **TUF Metadata**: http://localstack.local/tuf-metadata/

## Key Concepts

### TUF Roles
- **Root**: Master keys, rarely changes
- **Targets**: Lists available artifacts
- **Snapshot**: Version of all metadata
- **Timestamp**: Points to latest snapshot
- **Bins**: Delegated targets for scalability

### Key Types
- **Offline**: Stored securely, used manually (Root)
- **Online**: Stored on server, used automatically (Targets, Snapshot, Timestamp)

### Workflow
```
1. Ceremony → Generate keys, initialize RSTUF
2. Add Artifact → Register in metadata
3. Upload File → Store in S3
4. Client Download → Verify with TUF
```

## Production Checklist

- [ ] Use HTTPS everywhere
- [ ] Store keys in HSM/KMS
- [ ] Use multiple root keys (threshold 2+)
- [ ] Set up monitoring and alerting
- [ ] Configure auto-renewal for timestamp/snapshot
- [ ] Use managed services (RDS, ElastiCache, S3)
- [ ] Implement CDN for metadata
- [ ] Set up log aggregation
- [ ] Configure backups
- [ ] Document runbooks

## Getting Help

- **Docs**: https://repository-service-tuf.readthedocs.io/
- **Slack**: #repository-service-for-tuf on OpenSSF Slack
- **GitHub**: https://github.com/repository-service-tuf/repository-service-tuf
- **Meetings**: First Wednesday monthly, 15:00 UTC

## Quick Start Reminder

```bash
# 1. Start Minikube
minikube start --driver=docker
minikube addons enable ingress ingress-dns

# 2. Deploy RSTUF
helm repo add rstuf https://repository-service-tuf.github.io/helm-charts
helm upgrade --install rstuf rstuf/rstuf-demo -n rstuf --create-namespace

# 3. Configure DNS
echo "127.0.0.1 rstuf.local localstack.local" | sudo tee -a /etc/hosts

# 4. Start Tunnel (separate terminal)
minikube tunnel

# 5. Verify
curl http://rstuf.local/api/v1/

# 6. Ceremony
rstuf admin ceremony -b -u -f ceremony-payload.json

# 7. Add artifact
curl -X POST http://rstuf.local/api/v1/artifacts -H "Content-Type: application/json" -d @payload.json
```

---

**Print this page for quick reference while working with RSTUF!**
