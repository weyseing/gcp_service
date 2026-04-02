#!/bin/bash
# GCP Cost Checker — quick billing overview
# Usage: bash gcp-cost.sh

PROJECT="strategic-crow-341805"
BILLING_ACCOUNT="0124BA-24AE3F-C32866"

echo ""
echo "  GCP Billing · $(date '+%Y-%m-%d %H:%M')"
echo "  Project: $PROJECT"
echo "  Account: $BILLING_ACCOUNT (MYR)"
echo ""

# Collect active resources
echo "  Active Resources"
echo "  ────────────────────────────────────"
FOUND=0

# VMs
VMS=$(gcloud compute instances list --project="$PROJECT" --format="csv[no-heading](name,zone.basename(),machineType.basename(),status)" 2>/dev/null)
if [ -n "$VMS" ]; then
    FOUND=1
    while IFS=, read -r name zone type status; do
        echo "  VM    $name ($type, $zone) [$status]"
    done <<< "$VMS"
fi

# Disks
DISKS=$(gcloud compute disks list --project="$PROJECT" --format="csv[no-heading](name,sizeGb,type.basename())" 2>/dev/null)
if [ -n "$DISKS" ]; then
    FOUND=1
    while IFS=, read -r name size type; do
        echo "  Disk  $name (${size}GB, $type)"
    done <<< "$DISKS"
fi

# SQL
SQL=$(gcloud sql instances list --project="$PROJECT" --format="csv[no-heading](name,tier,state)" 2>/dev/null)
if [ -n "$SQL" ]; then
    FOUND=1
    while IFS=, read -r name tier state; do
        echo "  SQL   $name ($tier) [$state]"
    done <<< "$SQL"
fi

# GKE
GKE=$(gcloud container clusters list --project="$PROJECT" --format="csv[no-heading](name,location,currentNodeCount)" 2>/dev/null)
if [ -n "$GKE" ]; then
    FOUND=1
    while IFS=, read -r name loc nodes; do
        echo "  GKE   $name ($loc, ${nodes} nodes)"
    done <<< "$GKE"
fi

# Buckets
BUCKETS=$(gcloud storage ls --project="$PROJECT" 2>/dev/null)
if [ -n "$BUCKETS" ]; then
    FOUND=1
    for b in $BUCKETS; do
        echo "  GCS   $b"
    done
fi

if [ "$FOUND" -eq 0 ]; then
    echo "  (none — no active billable resources)"
fi

# Paid APIs worth noting
echo ""
echo "  Paid APIs Enabled"
echo "  ────────────────────────────────────"
gcloud services list --enabled --project="$PROJECT" --format="value(config.name)" 2>/dev/null | while read svc; do
    case "$svc" in
        compute.googleapis.com)              echo "  · Compute Engine" ;;
        container.googleapis.com)            echo "  · GKE" ;;
        sqladmin.googleapis.com)             echo "  · Cloud SQL" ;;
        aiplatform.googleapis.com)           echo "  · Vertex AI" ;;
        generativelanguage.googleapis.com)   echo "  · Gemini API" ;;
    esac
done

echo ""
echo "  https://console.cloud.google.com/billing/$BILLING_ACCOUNT/reports"
echo ""
