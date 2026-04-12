#!/bin/bash
# Build the sample Python application

set -e

echo "🔨 Building sample application..."

cd "$(dirname "$0")/../sample-artifacts/myapp"

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
source venv/bin/activate 2>/dev/null || source venv/Scripts/activate

# Install build tools
echo "Installing build tools..."
pip install --upgrade pip build wheel

# Build the package
echo "Building package..."
python -m build

echo "✅ Build complete!"
echo "📦 Package location: dist/"
ls -lh dist/

# Get package info
WHEEL_FILE=$(ls dist/*.whl | head -n 1)
TAR_FILE=$(ls dist/*.tar.gz | head -n 1)

echo ""
echo "📊 Package Information:"
echo "  Wheel: $(basename $WHEEL_FILE)"
echo "  Size: $(stat -f%z "$WHEEL_FILE" 2>/dev/null || stat -c%s "$WHEEL_FILE") bytes"
echo "  SHA256: $(sha256sum "$WHEEL_FILE" 2>/dev/null || shasum -a 256 "$WHEEL_FILE" | awk '{print $1}')"
echo ""
echo "  Tarball: $(basename $TAR_FILE)"
echo "  Size: $(stat -f%z "$TAR_FILE" 2>/dev/null || stat -c%s "$TAR_FILE") bytes"
echo "  SHA256: $(sha256sum "$TAR_FILE" 2>/dev/null || shasum -a 256 "$TAR_FILE" | awk '{print $1}')"
