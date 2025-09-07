#!/bin/bash

set -eu

# Check there's project id
if [ $# -lt 1 ]
then
  echo "Error: Please enter GCP Project ID"
  exit 1
fi

PROJECT_ID=${1}

# Debug
echo "Set GCP Project ID: ${PROJECT_ID}"

# Generate Terraform config file
echo "================================================================"
echo "Generate Terraform config file"

function generate_config() {
    sed "s/PROJECT_ID/${PROJECT_ID}/g" config.tf.tmpl > config.tf
    gcloud config set project "${PROJECT_ID}"
}

generate_config

echo "================================================================"
echo "Done"
