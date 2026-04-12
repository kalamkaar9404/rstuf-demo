# RSTUF Demo Project

> Hands-on demonstration of securing software artifacts with RSTUF

## 🎯 What This Demonstrates

- ✅ Deploy RSTUF locally
- ✅ Build a Python package
- ✅ Register with RSTUF
- ✅ Verify with TUF client
- ✅ Detect tampering

**Time**: 10-15 minutes | **Created for**: LFX Mentorship 2026

## 🚀 Quick Start

```bash
# 1. Setup RSTUF (one-time)
See GETTING-STARTED.md

# 2. Run demo
chmod +x demo-project/scripts/*.sh
./demo-project/scripts/run-demo.sh
```

## 📖 Documentation

| Document | Purpose |
|----------|---------|
| **[GETTING-STARTED.md](./GETTING-STARTED.md)** | 5-minute setup guide |
| **[DEMO-GUIDE.md](./DEMO-GUIDE.md)** | Complete demo script + video tips |
| **[QUICK-REFERENCE.md](./QUICK-REFERENCE.md)** | Command cheat sheet |
| **[tutorial/](./tutorial/)** | Full 6-part tutorial |

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

## 🎥 Recording Demo Video

1. **Setup**: Follow [GETTING-STARTED.md](./GETTING-STARTED.md)
2. **Practice**: Run demo 2-3 times
3. **Record**: Follow [DEMO-GUIDE.md](./DEMO-GUIDE.md) script
4. **Share**: Upload to YouTube/Vimeo

**Demo shows:**
- Building package
- Registering with RSTUF
- Verifying download
- Detecting tampering

## 🛠️ Technologies

Python • Docker • Minikube • Kubernetes • Helm • RSTUF • TUF

## 📧 Contact

**Khushboo** - LFX Mentorship 2026 Applicant

- GitHub: [@kalamkaar9404](https://github.com/kalamkaar9404)
- Repository: [rstuf-demo](https://github.com/kalamkaar9404/rstuf-demo)
- Slack: OpenSSF #repository-service-for-tuf

## 📄 License

MIT License

---

**New here?** → [GETTING-STARTED.md](./GETTING-STARTED.md)

**Ready to demo?** → [DEMO-GUIDE.md](./DEMO-GUIDE.md)
