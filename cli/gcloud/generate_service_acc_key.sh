#!/bin/bash
set -e

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
  echo "Generate .env with base64-encoded GCP service account key"
  echo ""
  echo "Usage: ./cli/gcp_key.sh <path/to/key.json>"
  echo ""
  echo "  path/to/key.json  Path to GCP service account key (required)"
  echo ""
  echo "Steps:"
  echo "  1. Download key.json from GCP Console (IAM > Service Accounts > Keys)"
  echo "  2. Run this script"
  echo "  3. GCP_SERVICE_KEY is updated in .env (or appended if missing)"
  exit 0
fi

if [ -z "$1" ]; then
  echo "Usage: ./cli/gcp_key.sh <path/to/key.json>"
  echo "Run ./cli/gcp_key.sh --help for more info"
  exit 1
fi

KEY_FILE="$1"

if [ ! -f "$KEY_FILE" ]; then
  echo "ERROR: $KEY_FILE not found" >&2
  exit 1
fi

ENV_FILE="${2:-.env}"
VALUE=$(base64 < "$KEY_FILE" | tr -d '\n')

if [ -f "$ENV_FILE" ] && grep -q '^GCP_SERVICE_KEY=' "$ENV_FILE"; then
  awk -v val="$VALUE" '/^GCP_SERVICE_KEY=/{print "GCP_SERVICE_KEY=" val; next} {print}' "$ENV_FILE" > "$ENV_FILE.tmp"
  mv "$ENV_FILE.tmp" "$ENV_FILE"
else
  echo "GCP_SERVICE_KEY=$VALUE" >> "$ENV_FILE"
fi

echo "Updated GCP_SERVICE_KEY in $ENV_FILE"
