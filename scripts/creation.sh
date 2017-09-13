#!/bin/bash

export DOMAIN_NAME="caseybuto.net"

export CLUSTER_ALIAS="usa"

export CLUSTER_FULL_NAME="${CLUSTER_ALIAS}.${DOMAIN_NAME}"

export CLUSTER_AWS_AZ="us-east-1a"

export CLUSTER_AWS_REGION="us-east-1"


echo "Create S3 bucket"

aws s3api create-bucket --bucket ${CLUSTER_FULL_NAME}-state
export KOPS_STATE_STORE="s3://${CLUSTER_FULL_NAME}-state"

echo "Create cluster"

kops create cluster \
--name=${CLUSTER_FULL_NAME} \
--zones=${CLUSTER_AWS_AZ} \
--master-size="t2.micro" \
--node-size="t2.micro" \
--node-count="2" \
--dns-zone=${DOMAIN_NAME} \
--ssh-public-key="~/.ssh/id_rsa.pub" \
--kubernetes-version="1.7.2" --yes

echo "Waiting for Kubernetes cluster to become available..."

until $(kubectl cluster-info &> /dev/null); do
    sleep 1
done

echo "Kubernetes cluster is up. Starting deployment."

kubectl create -f ./kubernetes/database/

kubectl create -f ./kubernetes/app/

echo "URL for the deployment"

kubectl get svc -o wide | grep "django-app-svc" | awk '{print $3}'
