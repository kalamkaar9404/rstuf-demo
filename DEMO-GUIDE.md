# RSTUF Demo Guide - Complete Walkthrough

> Step-by-step guide to demonstrate RSTUF with video recording tips

## 🎯 Demo Overview

This demo shows:
1. ✅ RSTUF deployment verification
2. 🔨 Building a Python package
3. 📤 Uploading to storage
4. 🔐 Registering with RSTUF
5. 📥 Downloading and verifying with TUF
6. 🚨 Detecting tampering

**Time**: ~10-15 minutes

## 📋 Prerequisites

Before starting the demo:

### 1. Install Required Tools

```bash
# Check installations
docker --version          # Should show v20+
minikube version         # Should show v1.x
helm version             # Should show v3.x
python --version         # Should show 3.10+
kubectl version --client # Should show v1.x
```

If missing, install:
- **Minikube**: https://minikube.sigs.k8s.io/docs/start/
- **kubectl**: https://kubernetes.io/docs/tasks/tools/
- Others should already be installed

### 2. Deploy RSTUF

```bash
# Start Minikube
minikube start --driver=docker

# Enable addons
minikube addons enable ingress
minikube addons enable ingress-dns

# Add RSTUF Helm repo
helm repo add rstuf https://repository-service-tuf.github.io/helm-charts
helm repo update

# Deploy RSTUF
helm upgrade --install rstuf rstuf/rstuf-demo -n rstuf --create-namespace

# Wait for pods (2-5 minutes)
kubectl get pods -n rstuf --watch
# Press Ctrl+C when all show 1/1 Running
```

### 3. Configure Networking

**Windows (PowerShell as Admin):**
```powershell
Add-Content -Path C:\Windows\System32\drivers\etc\hosts -Value "127.0.0.1 rstuf.local localstack.local"
```

**Linux/Mac:**
```bash
echo "127.0.0.1 rstuf.local localstack.local" | sudo tee -a /etc/hosts
```

### 4. Start Tunnel

**Open a separate terminal and keep it running:**
```bash
minikube tunnel
# Keep this terminal open!
```

### 5. Verify Setup

```bash
# Check API
curl http://rstuf.local/api/v1/
# Should return JSON with version info

# Check LocalStack
curl http://localstack.local/
# Should return {"status": "running"}
```

### 6. Run Ceremony

```bash
# Install RSTUF CLI
pip install repository-service-tuf-cli

# Setup environment
export AWS_ACCESS_KEY_ID=key
export AWS_SECRET_ACCESS_KEY=access
export AWS_DEFAULT_REGION=us-east-1
export AWS_ENDPOINT_URL=http://localstack.local

# Run ceremony
rstuf admin ceremony -b -u -f demo-project/ceremony/ceremony-config.json
```

**During ceremony, answer:**
- Use online key? `y`
- Key type? `1` (Local key)
- AWS settings: Use the values above

## 🎬 Demo Script

### Part 1: Verify Setup (1 min)

```bash
# Show RSTUF is running
./demo-project/scripts/verify-setup.sh
```

**What to say:**
> "First, let's verify RSTUF is running. This checks Minikube, pods, API, and LocalStack are all accessible."

**Expected output:**
```
✅ Minikube: Running
✅ RSTUF Pods: 5/5 ready
✅ Minikube Tunnel: Running
✅ RSTUF API: Accessible
✅ LocalStack: Accessible
✅ AWS CLI Config: Configured
✅ RSTUF Initialized: Yes
✅ RSTUF is ready to use!
```

### Part 2: Build Sample Application (2 min)

```bash
# Build the Python package
./demo-project/scripts/build-sample-app.sh
```

**What to say:**
> "Now I'll build a simple Python application. This creates a wheel package that we'll secure with RSTUF."

**Expected output:**
```
🔨 Building sample application...
✅ Build complete!
📦 Package location: dist/
  Wheel: rstuf_demo_app-1.0.0-py3-none-any.whl
  Size: 2847 bytes
  SHA256: [hash value]
```

**Show the file:**
```bash
ls -lh demo-project/sample-artifacts/myapp/dist/
```

### Part 3: Register with RSTUF (3 min)

```bash
# Register the artifact
./demo-project/scripts/register-artifact.sh \
  demo-project/sample-artifacts/myapp/dist/rstuf_demo_app-1.0.0-py3-none-any.whl \
  releases/rstuf_demo_app-1.0.0-py3-none-any.whl
```

**What to say:**
> "This script does three things: calculates the file hash, uploads to S3, and registers with RSTUF. RSTUF then creates signed TUF metadata for this artifact."

**Expected output:**
```
📦 Registering artifact with RSTUF...
🔍 Calculating metadata...
  SHA256: [hash]
  Size: 2847 bytes
📤 Uploading to storage...
✅ Uploaded to S3
🔐 Registering with RSTUF API...
  Task ID: [task-id]
⏳ Waiting for task completion...
✅ Artifact registered successfully!
```

### Part 4: Verify Registration (1 min)

```bash
# Check artifact in RSTUF
curl -s http://rstuf.local/api/v1/artifacts | jq '.data[] | select(.path | contains("rstuf_demo_app"))'
```

**What to say:**
> "Let's verify the artifact is registered in RSTUF. You can see the path, hash, and size are all recorded in the metadata."

**Show metadata:**
```bash
# Show TUF metadata was created
curl -s http://localstack.local/tuf-metadata/timestamp.json | jq '.'
```

### Part 5: Download and Verify (3 min)

```bash
# Install TUF client
pip install tuf

# Verify and download
python demo-project/verification/verify-download.py \
  releases/rstuf_demo_app-1.0.0-py3-none-any.whl
```

**What to say:**
> "Now I'll download the artifact using a TUF client. The client automatically verifies the signature and hash before accepting the file. This protects against tampering."

**Expected output:**
```
🔍 Verifying artifact: releases/rstuf_demo_app-1.0.0-py3-none-any.whl
📥 Initializing TUF client...
🔄 Refreshing TUF metadata...
✅ Metadata refreshed and verified
🔍 Looking up target...
✅ Target found in metadata
   Length: 2847 bytes
   SHA256: [hash]
📥 Downloading and verifying artifact...

============================================================
✅ SUCCESS! Artifact verified and downloaded
============================================================
📁 Downloaded to: downloads/releases/rstuf_demo_app-1.0.0-py3-none-any.whl
🎉 The artifact is authentic and has not been tampered with!
```

### Part 6: Demonstrate Tampering Detection (3 min)

```bash
# Create a malicious file
echo "MALICIOUS CODE" > malicious.whl

# Replace the artifact in S3
aws s3 cp malicious.whl s3://artifacts/releases/rstuf_demo_app-1.0.0-py3-none-any.whl

# Try to download again (should fail!)
python demo-project/verification/verify-download.py \
  releases/rstuf_demo_app-1.0.0-py3-none-any.whl
```

**What to say:**
> "Now let's see what happens if someone tampers with the file. I'll replace the artifact in S3 with a malicious file and try to download it again."

**Expected output:**
```
🔍 Verifying artifact...
📥 Downloading and verifying artifact...

============================================================
❌ VERIFICATION FAILED!
============================================================
Error: BadHashError: Hash mismatch
Expected: [original-hash]
Got: [different-hash]

⚠️  This could mean:
   - The artifact was tampered with
   - The metadata is invalid or expired

🛡️  DO NOT use this artifact!
```

**What to say:**
> "Perfect! TUF detected the tampering and blocked the download. This is how RSTUF protects your software supply chain."

### Part 7: Complete Demo Workflow (Optional)

```bash
# Run everything in one command
./demo-project/scripts/run-demo.sh
```

**What to say:**
> "I've also created a script that runs the entire workflow automatically. This is useful for CI/CD integration."

## 🎥 Video Recording Tips

### Setup

**Screen Recording Tools:**
- **Windows**: OBS Studio, ShareX
- **Mac**: QuickTime, ScreenFlow
- **Linux**: OBS Studio, SimpleScreenRecorder

**Settings:**
- Resolution: 1920x1080 (1080p)
- Frame rate: 30 fps
- Audio: Clear microphone
- Duration: 10-15 minutes

### Before Recording

1. **Clean your desktop**
   - Close unnecessary applications
   - Clear terminal history: `clear`
   - Use a clean terminal theme

2. **Increase font size**
   ```bash
   # Make terminal text readable
   # Zoom in or increase font to 16-18pt
   ```

3. **Prepare your script**
   - Have this guide open on another screen
   - Practice once before recording

4. **Test audio**
   - Record 10 seconds and play back
   - Ensure no background noise

### During Recording

**Introduction (30 seconds):**
```
"Hi, I'm [Your Name]. Today I'll demonstrate RSTUF - Repository Service 
for TUF - which secures software artifacts against tampering.

I'll show you how to:
1. Build a Python package
2. Register it with RSTUF
3. Verify downloads with TUF
4. Detect tampering attempts

Let's get started!"
```

**Tips:**
- Speak clearly and at moderate pace
- Explain what you're doing before typing
- Pause briefly after each command completes
- Point out important output
- Don't worry about small mistakes - keep going

**Conclusion (30 seconds):**
```
"That's RSTUF in action! We built a package, secured it with TUF metadata,
verified the download, and saw how tampering is detected.

This protects your software supply chain from attacks like we've seen with
SolarWinds and npm packages.

The complete code and tutorial are available on my GitHub. Thanks for watching!"
```

### After Recording

1. **Review the video**
   - Check audio quality
   - Verify all steps are visible
   - Ensure output is readable

2. **Edit (optional)**
   - Trim dead space
   - Add title slide
   - Add captions

3. **Export**
   - Format: MP4
   - Quality: High (1080p)
   - Size: Under 500MB if possible

4. **Upload**
   - YouTube (unlisted or public)
   - Vimeo
   - Google Drive (shareable link)

## 🐛 Troubleshooting

### Issue: Minikube not running
```bash
minikube start --driver=docker
```

### Issue: Pods not ready
```bash
kubectl get pods -n rstuf
kubectl logs -n rstuf <pod-name>
```

### Issue: Cannot access rstuf.local
```bash
# Check hosts file
cat /etc/hosts | grep rstuf  # Linux/Mac
type C:\Windows\System32\drivers\etc\hosts | findstr rstuf  # Windows

# Check tunnel
ps aux | grep "minikube tunnel"
```

### Issue: Script permission denied
```bash
chmod +x demo-project/scripts/*.sh
```

### Issue: AWS CLI errors
```bash
# Re-export environment variables
source demo-project/scripts/setup-env.sh
```

### Issue: Task stays pending
```bash
# Check worker logs
kubectl logs -n rstuf -l app=rstuf-worker --tail=50

# Restart worker
kubectl rollout restart deployment/rstuf-rstuf-worker -n rstuf
```

## 📝 Demo Checklist

Before recording:
- [ ] Minikube running
- [ ] All pods ready (5/5)
- [ ] Tunnel active
- [ ] API accessible
- [ ] Ceremony completed
- [ ] Scripts executable
- [ ] Environment variables set
- [ ] Terminal font size increased
- [ ] Desktop cleaned
- [ ] Audio tested

During demo:
- [ ] Introduce yourself
- [ ] Explain what RSTUF does
- [ ] Show each step clearly
- [ ] Explain the output
- [ ] Demonstrate tampering detection
- [ ] Conclude with summary

After recording:
- [ ] Review video quality
- [ ] Check audio clarity
- [ ] Verify all steps visible
- [ ] Upload to platform
- [ ] Share link

## 🎓 Key Points to Emphasize

1. **Problem**: Software supply chain attacks are real (SolarWinds, npm)
2. **Solution**: RSTUF uses TUF to cryptographically verify artifacts
3. **Process**: Build → Register → Verify → Detect tampering
4. **Benefit**: Automatic protection without changing existing workflows
5. **Integration**: Works with any CI/CD pipeline

## 📚 Additional Resources

- Full tutorial: `tutorial/README.md`
- Quick reference: `QUICK-REFERENCE.md`
- RSTUF docs: https://repository-service-tuf.readthedocs.io/

---

**Ready to record?** Follow this guide step-by-step and you'll have a great demo! 🎬