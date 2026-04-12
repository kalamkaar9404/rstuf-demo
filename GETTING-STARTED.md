# Getting Started - Quick Setup

## 🚀 5-Minute Quick Start

### Step 1: Install Prerequisites

```bash
# Check what you have
docker --version
minikube version
helm version
python --version
kubectl version --client
```

**Missing tools?**
- Minikube: https://minikube.sigs.k8s.io/docs/start/
- kubectl: https://kubernetes.io/docs/tasks/tools/

### Step 2: Deploy RSTUF

```bash
# Start Minikube
minikube start --driver=docker

# Enable addons
minikube addons enable ingress ingress-dns

# Add Helm repo
helm repo add rstuf https://repository-service-tuf.github.io/helm-charts
helm repo update

# Deploy
helm upgrade --install rstuf rstuf/rstuf-demo -n rstuf --create-namespace

# Wait for pods (2-5 min)
kubectl get pods -n rstuf --watch
```

### Step 3: Configure DNS

**Windows (PowerShell as Admin):**
```powershell
Add-Content -Path C:\Windows\System32\drivers\etc\hosts -Value "127.0.0.1 rstuf.local localstack.local"
```

**Linux/Mac:**
```bash
echo "127.0.0.1 rstuf.local localstack.local" | sudo tee -a /etc/hosts
```

### Step 4: Start Tunnel

**Open new terminal, keep it running:**
```bash
minikube tunnel
```

### Step 5: Run Ceremony

```bash
# Install CLI
pip install repository-service-tuf-cli

# Setup environment
export AWS_ACCESS_KEY_ID=key
export AWS_SECRET_ACCESS_KEY=access
export AWS_DEFAULT_REGION=us-east-1
export AWS_ENDPOINT_URL=http://localstack.local

# Run ceremony
rstuf admin ceremony -b -u -f demo-project/ceremony/ceremony-config.json
```

**Answer prompts:**
- Use online key? `y`
- Key type? `1`
- AWS settings: Use values above

### Step 6: Run Demo

```bash
# Make scripts executable
chmod +x demo-project/scripts/*.sh

# Run complete demo
./demo-project/scripts/run-demo.sh
```

## ✅ Success!

If you see:
```
✅ Demo completed successfully!
🎉 Your artifact is now secured with RSTUF!
```

You're ready to record your demo video!

## 📹 Next Steps

1. **Practice the demo**: Run it 2-3 times
2. **Read the demo guide**: [DEMO-GUIDE.md](./DEMO-GUIDE.md)
3. **Record your video**: Follow the script
4. **Share your work**: Upload and share!

## 🆘 Troubleshooting

**Pods not starting?**
```bash
kubectl get pods -n rstuf
kubectl logs -n rstuf <pod-name>
```

**Can't access rstuf.local?**
```bash
# Check tunnel is running
ps aux | grep "minikube tunnel"

# Restart if needed
minikube tunnel
```

**Scripts won't run?**
```bash
chmod +x demo-project/scripts/*.sh
```

**More help**: See [DEMO-GUIDE.md](./DEMO-GUIDE.md) troubleshooting section

---

**Ready?** Go to [DEMO-GUIDE.md](./DEMO-GUIDE.md) for the complete demo script!