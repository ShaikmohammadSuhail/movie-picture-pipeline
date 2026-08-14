#!/usr/bin/env bash
#
# init.sh - Grant the github-action-user IAM user access to the EKS cluster.
#
# This script:
#   1. Fetches the ARN of the IAM user named "github-action-user".
#   2. Uses the AWS IAM Authenticator to add that user to the Kubernetes
#      cluster's aws-auth ConfigMap with the system:masters group.
#
# Run this ONCE after the cluster has been created (via AWS console or the
# provided Terraform template).
#
# Requirements:
#   - aws CLI configured with administrator credentials
#   - kubectl configured for the target cluster (aws eks update-kubeconfig)
#   - CLUSTER_NAME environment variable (defaults to "cluster")
set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-cluster}"
REGION="${AWS_REGION:-us-east-1}"

echo "Fetching ARN for IAM user github-action-user ..."
userarn=$(aws iam get-user --user-name github-action-user \
  --query "User.Arn" --output text)

echo "Downloading AWS IAM Authenticator ..."
curl -o aws-iam-authenticator \
  https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.6.2/aws-iam-authenticator_$(uname -s)_amd64
chmod +x aws-iam-authenticator

echo "Adding ${userarn} to the Kubernetes cluster as github-action-role ..."
./aws-iam-authenticator \
  update-kubeconfig \
  --name "${CLUSTER_NAME}" \
  --region "${REGION}" \
  --role "${userarn}" \
  --user "github-action-role" \
  --groups "system:masters"

echo "Cleaning up ..."
rm -f aws-iam-authenticator

echo "Done. github-action-user can now run kubectl against the cluster."
