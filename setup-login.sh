#!/usr/bin/env bash

set -e # bail out early if any command fails
set -u # fail if we hit unset variables
set -o pipefail # fail if any component of any pipe fails

gcloud config set run/platform gke
gcloud config set project ${PROJECT_ID}

gcloud config set compute/zone ${ZONE}

gcloud config set run/cluster ${CLUSTER_NAME}
gcloud config set run/cluster_location ${ZONE}
gcloud container clusters get-credentials ${CLUSTER_NAME}

gcloud config set run/namespace ${NAMESPACE}
kubens ${NAMESPACE}
