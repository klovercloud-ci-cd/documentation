#!/bin/sh

read -p "Enter mongo server:" mongo_server
read -p "Enter mongo port:" mongo_port

#deploying tekton pipeline
kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/previous/v0.24.0/release.yaml

# Check deployment rollout status every 5 seconds (max 5 minutes) until complete.
ATTEMPTS=0
# shellcheck disable=SC2027
ROLLOUT_STATUS_CMD="kubectl rollout status deployment/tekton-pipelines-controller -n tekton-pipelines"
until $ROLLOUT_STATUS_CMD || [ $ATTEMPTS -eq 60 ]; do
  $ROLLOUT_STATUS_CMD
  # shellcheck disable=SC2154
  ATTEMPTS=$((attempts + 1))
  sleep 5
done

# Check deployment rollout status every 5 seconds (max 5 minutes) until complete.
ATTEMPTS=0
# shellcheck disable=SC2027
ROLLOUT_STATUS_CMD="kubectl rollout status deployment/tekton-pipelines-webhook -n tekton-pipelines"
until $ROLLOUT_STATUS_CMD || [ $ATTEMPTS -eq 60 ]; do
  $ROLLOUT_STATUS_CMD
  # shellcheck disable=SC2154
  ATTEMPTS=$((attempts + 1))
  sleep 5
done

# deploying event-bank
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/v1.0.0/descriptors/1.namespace.yaml
sed -i "/^\([[:space:]]*MONGO_SERVER: \).*/s//\1$mongo_server/" https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/v1.0.0/descriptors/2.configmap.yaml
sed -i "/^\([[:space:]]*MONGO_PORT: \).*/s//\1$mongo_port/" https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/v1.0.0/descriptors/2.configmap.yaml
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/v1.0.0/descriptors/2.configmap.yaml
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/v1.0.0/descriptors/3.mongo-secret.yaml
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/v1.0.0/descriptors/4.deployment.yaml

# Check deployment rollout status every 5 seconds (max 5 minutes) until complete.
ATTEMPTS=0
# shellcheck disable=SC2027
ROLLOUT_STATUS_CMD="kubectl rollout status deployment/klovercloud-ci-event-bank -n klovercloud"
until $ROLLOUT_STATUS_CMD || [ $ATTEMPTS -eq 60 ]; do
  $ROLLOUT_STATUS_CMD
  # shellcheck disable=SC2154
  ATTEMPTS=$((attempts + 1))
  sleep 5
done
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/v1.0.0/descriptors/18.service.yaml


# deploying api-service
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/v1.0.0/descriptors/5.configmap.yaml
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/v1.0.0/descriptors/6.deployment.yaml
# Check deployment rollout status every 5 seconds (max 5 minutes) until complete.
ATTEMPTS=0
# shellcheck disable=SC2027
ROLLOUT_STATUS_CMD="kubectl rollout status deployment/klovercloud-api-service -n klovercloud"
until $ROLLOUT_STATUS_CMD || [ $ATTEMPTS -eq 60 ]; do
  $ROLLOUT_STATUS_CMD
  # shellcheck disable=SC2154
  ATTEMPTS=$((attempts + 1))
  sleep 5
done
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/v1.0.0/descriptors/19.service.yaml


# deploying klovercloud-ci-integration-manager
sed -i "/^\([[:space:]]*MONGO_SERVER: \).*/s//\1$mongo_server/" https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/v1.0.0/descriptors/7.configmap.yaml
sed -i "/^\([[:space:]]*MONGO_PORT: \).*/s//\1$mongo_port/" https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/v1.0.0/descriptors/7.configmap.yaml
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/v1.0.0/descriptors/7.configmap.yaml
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/v1.0.0/descriptors/8.mongo-secret.yaml
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/v1.0.0/descriptors/9.deployment.yaml
# Check deployment rollout status every 5 seconds (max 5 minutes) until complete.
ATTEMPTS=0
# shellcheck disable=SC2027
ROLLOUT_STATUS_CMD="kubectl rollout status deployment/klovercloud-integration-manager -n klovercloud"
until $ROLLOUT_STATUS_CMD || [ $ATTEMPTS -eq 60 ]; do
  $ROLLOUT_STATUS_CMD
  # shellcheck disable=SC2154
  ATTEMPTS=$((attempts + 1))
  sleep 5
done
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/v1.0.0/descriptors/20.service.yaml


# deploying ci-core
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/v1.0.0/rbac/1.%20cluster-role.yaml
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/v1.0.0/rbac/2.service-account.yaml
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/v1.0.0/rbac/3.cluster-rolebinding.yaml
sed -i "/^\([[:space:]]*MONGO_SERVER: \).*/s//\1$mongo_server/" https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/v1.0.0/descriptors/10.configmap.yaml
sed -i "/^\([[:space:]]*MONGO_PORT: \).*/s//\1$mongo_port/" https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/v1.0.0/descriptors/10.configmap.yaml
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/v1.0.0/descriptors/10.configmap.yaml
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/v1.0.0/descriptors/11.mongo-secret.yaml
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/v1.0.0/descriptors/12.deployment.yaml
# Check deployment rollout status every 5 seconds (max 5 minutes) until complete.
ATTEMPTS=0
# shellcheck disable=SC2027
ROLLOUT_STATUS_CMD="kubectl rollout status deployment/klovercloud-ci-core -n klovercloud"
until $ROLLOUT_STATUS_CMD || [ $ATTEMPTS -eq 60 ]; do
  $ROLLOUT_STATUS_CMD
  # shellcheck disable=SC2154
  ATTEMPTS=$((attempts + 1))
  sleep 5
done
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/v1.0.0/descriptors/21.service.yaml

# deploying ci-agent
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/v1.0.0/rbac/4.cluster-role.yaml
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/v1.0.0/rbac/5.service-account.yaml
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/v1.0.0/rbac/6.cluster-rolebinding.yaml
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/v1.0.0/descriptors/13.configmap.yaml
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/v1.0.0/descriptors/14.deployment.yaml
# Check deployment rollout status every 5 seconds (max 5 minutes) until complete.
ATTEMPTS=0
# shellcheck disable=SC2027
ROLLOUT_STATUS_CMD="kubectl rollout status deployment/klovercloud-ci-agent -n klovercloud"
until $ROLLOUT_STATUS_CMD || [ $ATTEMPTS -eq 60 ]; do
  $ROLLOUT_STATUS_CMD
  # shellcheck disable=SC2154
  ATTEMPTS=$((attempts + 1))
  sleep 5
done
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/v1.0.0/descriptors/22.service.yaml


# deploying security
sed -i "/^\([[:space:]]*MONGO_SERVER: \).*/s//\1$mongo_server/" https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/v1.0.0/descriptors/15.configmap.yml
sed -i "/^\([[:space:]]*MONGO_PORT: \).*/s//\1$mongo_port/" https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/v1.0.0/descriptors/15.configmap.yml

kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/v1.0.0/descriptors/15.configmap.yml
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/v1.0.0/descriptors/16.mongo-secret.yml
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/v1.0.0/descriptors/17.deployment.yaml
# Check deployment rollout status every 5 seconds (max 5 minutes) until complete.
ATTEMPTS=0
# shellcheck disable=SC2027
ROLLOUT_STATUS_CMD="kubectl rollout status deployment/klovercloud-security -n klovercloud"
until $ROLLOUT_STATUS_CMD || [ $ATTEMPTS -eq 60 ]; do
  $ROLLOUT_STATUS_CMD
  # shellcheck disable=SC2154
  ATTEMPTS=$((attempts + 1))
  sleep 5
done
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/v1.0.0/descriptors/23.service.yaml

kubectl get pods -n klovercloud

