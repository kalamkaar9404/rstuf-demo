#!/bin/bash
# Verify RSTUF setup is working

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "🔍 RSTUF Setup Verification"
echo "============================"
echo ""

# Check Minikube
echo -n "Minikube: "
if minikube status | grep -q "Running"; then
    echo -e "${GREEN}✅ Running${NC}"
else
    echo -e "${RED}❌ Not running${NC}"
    echo "  Run: minikube start --driver=docker"
fi

# Check Kubernetes pods
echo -n "RSTUF Pods: "
READY=$(kubectl get pods -n rstuf --no-headers 2>/dev/null | grep -c "1/1.*Running" || echo "0")
TOTAL=$(kubectl get pods -n rstuf --no-headers 2>/dev/null | wc -l || echo "0")
if [ "$READY" -eq "$TOTAL" ] && [ "$TOTAL" -gt "0" ]; then
    echo -e "${GREEN}✅ $READY/$TOTAL ready${NC}"
else
    echo -e "${YELLOW}⚠️  $READY/$TOTAL ready${NC}"
    if [ "$TOTAL" -eq "0" ]; then
        echo "  Run: helm upgrade --install rstuf rstuf/rstuf-demo -n rstuf --create-namespace"
    fi
fi

# Check tunnel
echo -n "Minikube Tunnel: "
if ps aux | grep -q "[m]inikube tunnel"; then
    echo -e "${GREEN}✅ Running${NC}"
else
    echo -e "${RED}❌ Not running${NC}"
    echo "  Run in separate terminal: minikube tunnel"
fi

# Check RSTUF API
echo -n "RSTUF API: "
if curl -s http://rstuf.local/api/v1/ > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Accessible${NC}"
    VERSION=$(curl -s http://rstuf.local/api/v1/ | jq -r '.data.version' 2>/dev/null || echo "unknown")
    echo "  Version: $VERSION"
else
    echo -e "${RED}❌ Not accessible${NC}"
    echo "  Check: curl http://rstuf.local/api/v1/"
fi

# Check LocalStack
echo -n "LocalStack: "
if curl -s http://localstack.local/ > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Accessible${NC}"
else
    echo -e "${RED}❌ Not accessible${NC}"
    echo "  Check: curl http://localstack.local/"
fi

# Check AWS CLI configuration
echo -n "AWS CLI Config: "
if [ -n "$AWS_ACCESS_KEY_ID" ] && [ -n "$AWS_ENDPOINT_URL" ]; then
    echo -e "${GREEN}✅ Configured${NC}"
else
    echo -e "${YELLOW}⚠️  Not configured${NC}"
    echo "  Run: source demo-project/scripts/setup-env.sh"
fi

# Check if ceremony was done
echo -n "RSTUF Initialized: "
if curl -s http://localstack.local/tuf-metadata/1.root.json > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Yes${NC}"
else
    echo -e "${YELLOW}⚠️  No${NC}"
    echo "  Run: rstuf admin ceremony -b -u -f demo-project/ceremony/ceremony-config.json"
fi

echo ""
echo "============================"

# Overall status
if curl -s http://rstuf.local/api/v1/ > /dev/null 2>&1 && \
   curl -s http://localstack.local/tuf-metadata/1.root.json > /dev/null 2>&1; then
    echo -e "${GREEN}✅ RSTUF is ready to use!${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠️  RSTUF setup incomplete${NC}"
    echo "Follow the tutorial to complete setup."
    exit 1
fi
