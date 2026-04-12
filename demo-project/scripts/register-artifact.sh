#!/bin/bash
# Register an artifact with RSTUF

set -e

# Configuration
RSTUF_API_URL="${RSTUF_API_URL:-http://rstuf.local}"
ARTIFACT_FILE="$1"
STORAGE_PATH="$2"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

if [ -z "$ARTIFACT_FILE" ] || [ -z "$STORAGE_PATH" ]; then
    echo -e "${RED}Usage: $0 <artifact-file> <storage-path>${NC}"
    echo ""
    echo "Example:"
    echo "  $0 dist/myapp-1.0.0.whl releases/myapp-1.0.0.whl"
    exit 1
fi

if [ ! -f "$ARTIFACT_FILE" ]; then
    echo -e "${RED}Error: File not found: $ARTIFACT_FILE${NC}"
    exit 1
fi

echo -e "${YELLOW}📦 Registering artifact with RSTUF...${NC}"
echo "  File: $ARTIFACT_FILE"
echo "  Path: $STORAGE_PATH"
echo ""

# Calculate metadata
echo "🔍 Calculating metadata..."
HASH=$(sha256sum "$ARTIFACT_FILE" 2>/dev/null || shasum -a 256 "$ARTIFACT_FILE" | awk '{print $1}')
SIZE=$(stat -c%s "$ARTIFACT_FILE" 2>/dev/null || stat -f%z "$ARTIFACT_FILE")

echo "  SHA256: $HASH"
echo "  Size: $SIZE bytes"
echo ""

# Upload to S3 (LocalStack)
echo "📤 Uploading to storage..."
export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:-key}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:-access}
export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-us-east-1}
export AWS_ENDPOINT_URL=${AWS_ENDPOINT_URL:-http://localstack.local}

aws s3 cp "$ARTIFACT_FILE" "s3://artifacts/$STORAGE_PATH" || {
    echo -e "${RED}❌ Failed to upload to S3${NC}"
    exit 1
}

echo -e "${GREEN}✅ Uploaded to S3${NC}"
echo ""

# Create payload
PAYLOAD=$(cat <<EOF
{
  "artifacts": [{
    "path": "$STORAGE_PATH",
    "info": {
      "length": $SIZE,
      "hashes": {
        "sha256": "$HASH"
      },
      "custom": {
        "uploaded_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
        "filename": "$(basename $ARTIFACT_FILE)"
      }
    }
  }]
}
EOF
)

# Register with RSTUF
echo "🔐 Registering with RSTUF API..."
RESPONSE=$(curl -s -X POST "${RSTUF_API_URL}/api/v1/artifacts" \
    -H "Content-Type: application/json" \
    -d "$PAYLOAD")

TASK_ID=$(echo "$RESPONSE" | jq -r '.data.task_id' 2>/dev/null)

if [ "$TASK_ID" = "null" ] || [ -z "$TASK_ID" ]; then
    echo -e "${RED}❌ Failed to submit task${NC}"
    echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
    exit 1
fi

echo "  Task ID: $TASK_ID"
echo ""

# Wait for completion
echo "⏳ Waiting for task completion..."
for i in {1..30}; do
    sleep 2
    STATUS_RESPONSE=$(curl -s "${RSTUF_API_URL}/api/v1/task?task_id=${TASK_ID}")
    STATUS=$(echo "$STATUS_RESPONSE" | jq -r '.data.state' 2>/dev/null)
    
    case "$STATUS" in
        SUCCESS)
            echo -e "${GREEN}✅ Artifact registered successfully!${NC}"
            echo ""
            echo "📋 Summary:"
            echo "  Path: $STORAGE_PATH"
            echo "  SHA256: $HASH"
            echo "  Size: $SIZE bytes"
            echo "  Task ID: $TASK_ID"
            exit 0
            ;;
        FAILURE)
            echo -e "${RED}❌ Registration failed!${NC}"
            echo "$STATUS_RESPONSE" | jq '.data.result' 2>/dev/null || echo "$STATUS_RESPONSE"
            exit 1
            ;;
        *)
            echo -n "."
            ;;
    esac
done

echo ""
echo -e "${YELLOW}⏱️  Timeout waiting for registration${NC}"
echo "Task ID: $TASK_ID"
echo "Check status manually: curl '${RSTUF_API_URL}/api/v1/task?task_id=${TASK_ID}'"
exit 1
