#!/bin/bash
set -e

# Authenticate with GCP
if [ -n "$GOOGLE_APPLICATION_CREDENTIALS" ] && [ -f "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
  # Non-interactive: use service account key
  gcloud auth activate-service-account --key-file="$GOOGLE_APPLICATION_CREDENTIALS"
elif ! gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>/dev/null | grep -q "@"; then
  # Interactive: browser login (first time only, cached in ~/.config/gcloud volume)
  echo "No active GCP account found. Starting browser login..."
  gcloud auth login
fi

# Verify auth
echo "---GCP Auth---"
gcloud auth list
echo "---GCP Config---"
gcloud config list
echo "---GCP Projects---"
gcloud projects list

exec bash "$@"
