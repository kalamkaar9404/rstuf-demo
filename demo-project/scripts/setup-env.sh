#!/bin/bash
# Setup environment variables for RSTUF demo

# AWS/LocalStack configuration
export AWS_ACCESS_KEY_ID=key
export AWS_SECRET_ACCESS_KEY=access
export AWS_DEFAULT_REGION=us-east-1
export AWS_ENDPOINT_URL=http://localstack.local

# RSTUF API configuration
export RSTUF_API_URL=http://rstuf.local

echo "✅ Environment variables set:"
echo "  AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID"
echo "  AWS_SECRET_ACCESS_KEY=***"
echo "  AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION"
echo "  AWS_ENDPOINT_URL=$AWS_ENDPOINT_URL"
echo "  RSTUF_API_URL=$RSTUF_API_URL"
echo ""
echo "To use in your current shell, run:"
echo "  source demo-project/scripts/setup-env.sh"
