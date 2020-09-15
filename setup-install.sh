#!/usr/bin/env bash

set -e # bail out early if any command fails
set -u # fail if we hit unset variables
set -o pipefail # fail if any component of any pipe fails

gcloud config set run/platform gke
gcloud config set project ${PROJECT_ID}

gcloud config set compute/zone ${ZONE}

gcloud services enable container.googleapis.com containerregistry.googleapis.com cloudbuild.googleapis.com

gcloud container clusters create ${CLUSTER_NAME} \
  --addons=HttpLoadBalancing,CloudRun \
  --machine-type=n1-standard-2 \
  --num-nodes=3 \
  --enable-stackdriver-kubernetes \
  --zone=${ZONE}

gcloud config set run/cluster ${CLUSTER_NAME}
gcloud config set run/cluster_location ${ZONE}
gcloud container clusters get-credentials ${CLUSTER_NAME}

kubectl create namespace ${NAMESPACE}
gcloud config set run/namespace ${NAMESPACE}

kubectl patch cm config-domainmapping -n knative-serving -p '{"data":{"autoTLS":"Disabled"}}'
kubectl annotate domainmappings ${DOMAIN} domains.cloudrun.com/disableAutoTLS=true
gcloud run domain-mappings describe --domain=${DOMAIN}gcloud run domain-mappings describe --domain=${DOMAIN}