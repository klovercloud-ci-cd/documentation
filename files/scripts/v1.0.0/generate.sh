#!/bin/sh

read -p "Enter mongo server:" mongo_server
read -p "Enter mongo port:" mongo_port


# deploying event-bank
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/descriptors/1.namespace.yaml
sed -i "/^\([[:space:]]*MONGO_SERVER: \).*/s//\1$mongo_server/" https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/descriptors/2.configmap.yaml
sed -i "/^\([[:space:]]*MONGO_PORT: \).*/s//\1$mongo_port/" https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/descriptors/2.configmap.yaml
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/descriptors/2.configmap.yaml
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/descriptors/3.mongo-secret.yaml
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/descriptors/4.deployment.yaml

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
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/descriptors/18.service.yaml


# deploying api-service
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/descriptors/5.configmap.yaml
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/descriptors/6.deployment.yaml
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
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/descriptors/19.service.yaml


# deploying klovercloud-ci-integration-manager
sed -i "/^\([[:space:]]*MONGO_SERVER: \).*/s//\1$mongo_server/" https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/descriptors/7.configmap.yaml
sed -i "/^\([[:space:]]*MONGO_PORT: \).*/s//\1$mongo_port/" https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/descriptors/7.configmap.yaml
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/descriptors/7.configmap.yaml
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/descriptors/8.mongo-secret.yaml
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/descriptors/9.deployment.yaml
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
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/descriptors/20.service.yaml


# deploying ci-core
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/permissions/1.%20cluster-role.yaml
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/permissions/2.service-account.yaml
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/permissions/3.cluster-rolebinding.yaml
sed -i "/^\([[:space:]]*MONGO_SERVER: \).*/s//\1$mongo_server/" https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/descriptors/10.configmap.yaml
sed -i "/^\([[:space:]]*MONGO_PORT: \).*/s//\1$mongo_port/" https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/descriptors/10.configmap.yaml
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/descriptors/10.configmap.yaml
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/descriptors/11.mongo-secret.yaml
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/descriptors/12.deployment.yaml
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
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/descriptors/21.service.yaml

# deploying ci-agent
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/permissions/4.cluster-role.yaml
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/permissions/5.service-account.yaml
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/permissions/6.cluster-rolebinding.yaml
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/descriptors/13.configmap.yaml
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/descriptors/14.deployment.yaml
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
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/descriptors/22.service.yaml


# deploying security
sed -i "/^\([[:space:]]*MONGO_SERVER: \).*/s//\1$mongo_server/" https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/descriptors/15.configmap.yml
sed -i "/^\([[:space:]]*MONGO_PORT: \).*/s//\1$mongo_port/" https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/descriptors/15.configmap.yml

kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/descriptors/15.configmap.yml
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/descriptors/16.mongo-secret.yml
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/descriptors/17.deployment.yaml
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
kubectl apply -f https://raw.githubusercontent.com/klovercloud-ci-cd/documentation/main/files/k8s/descriptors/23.service.yaml

kubectl get pods -n klovercloud

