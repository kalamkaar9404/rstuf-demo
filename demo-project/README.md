# RSTUF Demo Project - Working Examples

This directory contains **actual working code** that accompanies the tutorial. Use these examples to practice RSTUF workflows.

## 📁 Structure

```
demo-project/
├── sample-artifacts/          # Sample Python app to secure
│   └── myapp/
│       ├── app.py            # Simple Python application
│       ├── setup.py          # Package configuration
│       └── dist/             # Built packages (created by build script)
│
├── scripts/                   # Helper scripts
│   ├── build-sample-app.sh   # Build the Python package
│   ├── register-artifact.sh  # Register artifact with RSTUF
│   ├── verify-setup.sh       # Check if RSTUF is ready
│   ├── setup-env.sh          # Set environment variables
│   └── run-demo.sh           # Complete demo workflow
│
├── ceremony/                  # Ceremony configuration
│   └── ceremony-config.json  # RSTUF initialization config
│
├── ci-cd-examples/            # CI/CD workflow examples
│   └── github-actions-demo.yml  # GitHub Actions workflow
│
└── verification/              # TUF client verification
    └── verify-download.py    # Download and verify with TUF
```

## 🚀 Quick Start

### Prerequisites

1. Complete the tutorial through Part 3 (RSTUF deployed locally)
2. RSTUF ceremony completed (Part 4)
3. Environment variables set

### Run the Complete Demo

```bash
# Make scripts executable
chmod +x demo-project/scripts/*.sh

# Run the complete demo workflow
./demo-project/scripts/run-demo.sh
```

This will:
1. ✅ Verify RSTUF setup
2. 🔨 Build sample Python package
3. 📤 Upload to S3
4. 🔐 Register with RSTUF
5. 📥 Download and verify

## 📚 Individual Examples

### 1. Build Sample Application

```bash
./demo-project/scripts/build-sample-app.sh
```

Creates a Python wheel package in `sample-artifacts/myapp/dist/`

### 2. Setup Environment

```bash
source ./demo-project/scripts/setup-env.sh
```

Sets AWS and RSTUF environment variables.

### 3. Verify RSTUF Setup

```bash
./demo-project/scripts/verify-setup.sh
```

Checks if RSTUF is running and configured correctly.

### 4. Register an Artifact

```bash
# Build first
./demo-project/scripts/build-sample-app.sh

# Register
./demo-project/scripts/register-artifact.sh \
  demo-project/sample-artifacts/myapp/dist/rstuf_demo_app-1.0.0-py3-none-any.whl \
  releases/rstuf_demo_app-1.0.0-py3-none-any.whl
```

### 5. Verify with TUF Client

```bash
# Install TUF client
pip install tuf

# Verify and download
python demo-project/verification/verify-download.py \
  releases/rstuf_demo_app-1.0.0-py3-none-any.whl
```

## 🔧 Scripts Reference

### build-sample-app.sh

Builds the sample Python application.

**Usage:**
```bash
./demo-project/scripts/build-sample-app.sh
```

**Output:**
- Wheel file: `sample-artifacts/myapp/dist/*.whl`
- Tarball: `sample-artifacts/myapp/dist/*.tar.gz`
- Package metadata (hash, size)

### register-artifact.sh

Registers an artifact with RSTUF.

**Usage:**
```bash
./demo-project/scripts/register-artifact.sh <file> <storage-path>
```

**Example:**
```bash
./demo-project/scripts/register-artifact.sh \
  dist/myapp-1.0.0.whl \
  releases/myapp-1.0.0.whl
```

**What it does:**
1. Calculates SHA256 hash
2. Uploads to S3
3. Registers with RSTUF API
4. Waits for task completion

### verify-setup.sh

Checks if RSTUF is ready to use.

**Usage:**
```bash
./demo-project/scripts/verify-setup.sh
```

**Checks:**
- ✅ Minikube running
- ✅ Pods ready
- ✅ Tunnel active
- ✅ API accessible
- ✅ LocalStack accessible
- ✅ Environment configured
- ✅ Ceremony completed

### setup-env.sh

Sets required environment variables.

**Usage:**
```bash
source ./demo-project/scripts/setup-env.sh
```

**Sets:**
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_DEFAULT_REGION`
- `AWS_ENDPOINT_URL`
- `RSTUF_API_URL`

### run-demo.sh

Runs the complete demo workflow.

**Usage:**
```bash
./demo-project/scripts/run-demo.sh
```

**Steps:**
1. Verify setup
2. Setup environment
3. Build sample app
4. Register with RSTUF
5. Verify registration
6. Download and verify

## 🎯 Use Cases

### Use Case 1: Test RSTUF Locally

```bash
# Complete workflow
./demo-project/scripts/run-demo.sh
```

### Use Case 2: Practice Artifact Registration

```bash
# Create your own file
echo "Hello RSTUF!" > myfile.txt

# Register it
./demo-project/scripts/register-artifact.sh myfile.txt test/myfile.txt

# Verify
python demo-project/verification/verify-download.py test/myfile.txt
```

### Use Case 3: Test Tampering Detection

```bash
# Register an artifact
./demo-project/scripts/register-artifact.sh myfile.txt test/myfile.txt

# Tamper with it in S3
echo "HACKED!" > tampered.txt
aws s3 cp tampered.txt s3://artifacts/test/myfile.txt

# Try to verify (should fail!)
python demo-project/verification/verify-download.py test/myfile.txt
# ❌ Verification will fail - hash mismatch!
```

### Use Case 4: CI/CD Integration

Copy the GitHub Actions workflow:

```bash
# Copy to your repo
cp demo-project/ci-cd-examples/github-actions-demo.yml \
   .github/workflows/release.yml

# Configure secrets in GitHub:
# - AWS_ACCESS_KEY_ID
# - AWS_SECRET_ACCESS_KEY
# - AWS_ENDPOINT_URL
# - RSTUF_API_URL
```

## 🐛 Troubleshooting

### Script Permission Denied

```bash
chmod +x demo-project/scripts/*.sh
```

### AWS CLI Not Found

```bash
pip install awscli
```

### TUF Client Not Found

```bash
pip install tuf
```

### RSTUF Not Accessible

```bash
# Check setup
./demo-project/scripts/verify-setup.sh

# Ensure tunnel is running
minikube tunnel
```

### Task Stays Pending

```bash
# Check worker logs
kubectl logs -n rstuf -l app=rstuf-worker --tail=50

# Restart worker
kubectl rollout restart deployment/rstuf-rstuf-worker -n rstuf
```

## 📖 Related Documentation

- [Tutorial Part 4](../tutorial/04-ceremony-and-first-artifact.md) - Ceremony and first artifact
- [Tutorial Part 5](../tutorial/05-cicd-integration.md) - CI/CD integration
- [Quick Reference](../QUICK-REFERENCE.md) - Command reference

## 🤝 Contributing

Found an issue or want to add examples?

1. Test your changes
2. Update documentation
3. Submit a pull request

## 📝 License

MIT License - feel free to use and modify!
