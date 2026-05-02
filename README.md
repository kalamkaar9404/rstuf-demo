# RSTUF Demo Project

> Hands-on demonstration of securing software artifacts with RSTUF

## What This Demonstrates

- Deploy RSTUF locally
- Build a Python package
- Register with RSTUF
- Verify with TUF client
- Detect tampering


## Quick Start

```bash
# 1. Setup RSTUF (one-time)
See GETTING-STARTED.md

# 2. Run demo
chmod +x demo-project/scripts/*.sh
./demo-project/scripts/run-demo.sh
```


## 📁 Project Structure

```
demo-project/
├── sample-artifacts/myapp/    # Python app
│   ├── app.py
│   └── setup.py
├── scripts/                   # Automation
│   ├── build-sample-app.sh
│   ├── register-artifact.sh
│   ├── verify-setup.sh
│   ├── setup-env.sh
│   └── run-demo.sh
├── ceremony/                  # Config
│   └── ceremony-config.json
├── ci-cd-examples/            # GitHub Actions
│   └── github-actions-demo.yml
└── verification/              # TUF client
    └── verify-download.py
```


## 🛠️ Technologies

Python • Docker • Minikube • Kubernetes • Helm • RSTUF • TUF


- GitHub: [@kalamkaar9404](https://github.com/kalamkaar9404)
- Repository: [rstuf-demo](https://github.com/kalamkaar9404/rstuf-demo)
- Slack: OpenSSF #repository-service-for-tuf

## 📄 License

MIT License

---

**DOC** → [GETTING-STARTED.md](./GETTING-STARTED.md)
