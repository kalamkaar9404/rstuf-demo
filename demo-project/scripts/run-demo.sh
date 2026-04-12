#!/bin/bash
# Complete demo workflow

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🚀 RSTUF Complete Demo Workflow${NC}"
echo "=================================="
echo ""

# Step 1: Verify setup
echo -e "${YELLOW}Step 1: Verifying RSTUF setup...${NC}"
bash "$SCRIPT_DIR/verify-setup.sh" || {
    echo ""
    echo -e "${YELLOW}⚠️  Setup incomplete. Please follow the tutorial first.${NC}"
    exit 1
}
echo ""

# Step 2: Setup environment
echo -e "${YELLOW}Step 2: Setting up environment...${NC}"
source "$SCRIPT_DIR/setup-env.sh"
echo ""

# Step 3: Build sample app
echo -e "${YELLOW}Step 3: Building sample application...${NC}"
bash "$SCRIPT_DIR/build-sample-app.sh"
echo ""

# Step 4: Register artifact
echo -e "${YELLOW}Step 4: Registering artifact with RSTUF...${NC}"
WHEEL_FILE=$(ls "$PROJECT_ROOT/sample-artifacts/myapp/dist/"*.whl | head -n 1)
if [ -z "$WHEEL_FILE" ]; then
    echo "Error: No wheel file found"
    exit 1
fi

FILENAME=$(basename "$WHEEL_FILE")
bash "$SCRIPT_DIR/register-artifact.sh" "$WHEEL_FILE" "releases/$FILENAME"
echo ""

# Step 5: Verify registration
echo -e "${YELLOW}Step 5: Verifying registration...${NC}"
echo "Checking RSTUF API for artifact..."
curl -s http://rstuf.local/api/v1/artifacts | jq ".data[] | select(.path==\"releases/$FILENAME\")" || {
    echo "Artifact not found in API response"
}
echo ""

# Step 6: Download and verify
echo -e "${YELLOW}Step 6: Testing download and verification...${NC}"
echo "Downloading artifact from S3..."
mkdir -p "$PROJECT_ROOT/downloads"
aws s3 cp "s3://artifacts/releases/$FILENAME" "$PROJECT_ROOT/downloads/$FILENAME"

echo "Verifying hash..."
ORIGINAL_HASH=$(sha256sum "$WHEEL_FILE" 2>/dev/null || shasum -a 256 "$WHEEL_FILE" | awk '{print $1}')
DOWNLOADED_HASH=$(sha256sum "$PROJECT_ROOT/downloads/$FILENAME" 2>/dev/null || shasum -a 256 "$PROJECT_ROOT/downloads/$FILENAME" | awk '{print $1}')

if [ "$ORIGINAL_HASH" = "$DOWNLOADED_HASH" ]; then
    echo -e "${GREEN}✅ Hash verification passed!${NC}"
    echo "  Original:   $ORIGINAL_HASH"
    echo "  Downloaded: $DOWNLOADED_HASH"
else
    echo -e "${RED}❌ Hash mismatch!${NC}"
    echo "  Original:   $ORIGINAL_HASH"
    echo "  Downloaded: $DOWNLOADED_HASH"
    exit 1
fi
echo ""

# Success!
echo "=================================="
echo -e "${GREEN}✅ Demo completed successfully!${NC}"
echo ""
echo "📋 Summary:"
echo "  1. ✅ RSTUF setup verified"
echo "  2. ✅ Sample app built"
echo "  3. ✅ Artifact registered with RSTUF"
echo "  4. ✅ Artifact uploaded to S3"
echo "  5. ✅ Download and verification successful"
echo ""
echo "🎉 Your artifact is now secured with RSTUF!"
echo ""
echo "Next steps:"
echo "  - Try modifying the artifact and see verification fail"
echo "  - Add more artifacts"
echo "  - Integrate with your CI/CD pipeline"
