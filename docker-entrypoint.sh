#!/bin/bash
set -e

# Decode base64 service account key to fixed path
echo "$GCP_SERVICE_KEY" | base64 -d > /tmp/gcp-key.json
gcloud auth activate-service-account --key-file=/tmp/gcp-key.json
echo "Authenticated as: $(gcloud auth list --filter=status:ACTIVE --format='value(account)')"

exec bash "$@"
