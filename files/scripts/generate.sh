#!/bin/sh
read -p "Enter mongo server:" mongo_server
read -p "Enter mongo port:" mongo_port


# deploying event-bank
kubectl apply -f ../event-bank/k8s/namespace.yaml
sed -i "/^\([[:space:]]*MONGO_SERVER: \).*/s//\1$mongo_server/" ../event-bank/k8s/configmap.yaml
sed -i "/^\([[:space:]]*MONGO_PORT: \).*/s//\1$mongo_port/" ../event-bank/k8s/configmap.yaml
kubectl apply -f ../event-bank/k8s/configmap.yaml
kubectl apply -f ../event-bank/k8s/mongo-secret.yaml
kubectl apply -f ../event-bank/k8s/deployment.yaml

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
kubectl apply -f ../event-bank/k8s/service.yaml


# deploying api-service
kubectl apply -f ../api-service/k8s/configmap.yaml
kubectl apply -f ../api-service/k8s/deployment.yaml
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
kubectl apply -f ../api-service/k8s/service.yaml


# deploying klovercloud-ci-integration-manager
sed -i "/^\([[:space:]]*MONGO_SERVER: \).*/s//\1$mongo_server/" ../klovercloud-ci-integration-manager/k8s/configmap.yaml
sed -i "/^\([[:space:]]*MONGO_PORT: \).*/s//\1$mongo_port/" ../klovercloud-ci-integration-manager/k8s/configmap.yaml
kubectl apply -f ../klovercloud-ci-integration-manager/k8s/configmap.yaml
kubectl apply -f ../klovercloud-ci-integration-manager/k8s/mongo-secret.yaml
kubectl apply -f ../klovercloud-ci-integration-manager/k8s/deployment.yaml
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
kubectl apply -f ../klovercloud-ci-integration-manager/k8s/service.yaml


# deploying ci-core
kubectl apply -f ../klovercloud-ci-core/k8s/cluster-role.yaml
kubectl apply -f ../klovercloud-ci-core/k8s/service-account.yaml
kubectl apply -f ../klovercloud-ci-core/k8s/cluster-rolebinding.yaml
sed -i "/^\([[:space:]]*MONGO_SERVER: \).*/s//\1$mongo_server/" ../klovercloud-ci-core/k8s/configmap.yaml
sed -i "/^\([[:space:]]*MONGO_PORT: \).*/s//\1$mongo_port/" ../klovercloud-ci-core/k8s/configmap.yaml
kubectl apply -f ../klovercloud-ci-core/k8s/configmap.yaml
kubectl apply -f ../klovercloud-ci-core/k8s/mongo-secret.yaml
kubectl apply -f ../klovercloud-ci-core/k8s/deployment.yaml
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
kubectl apply -f ../klovercloud-ci-core/k8s/service.yaml

# deploying ci-agent
kubectl apply -f ../klovercloud-ci-agent/k8s/cluster-role.yaml
kubectl apply -f ../klovercloud-ci-agent/k8s/service-account.yaml
kubectl apply -f ../klovercloud-ci-agent/k8s/cluster-rolebinding.yaml
kubectl apply -f ../klovercloud-ci-agent/k8s/configmap.yaml
kubectl apply -f ../klovercloud-ci-agent/k8s/deployment.yaml
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
kubectl apply -f ../klovercloud-ci-agent/k8s/service.yaml


# deploying security
sed -i "/^\([[:space:]]*MONGO_SERVER: \).*/s//\1$mongo_server/" ../security/k8s/configmap.yaml
sed -i "/^\([[:space:]]*MONGO_PORT: \).*/s//\1$mongo_port/" ../security/k8s/configmap.yaml

kubectl apply -f ../security/k8s/configmap.yaml
kubectl apply -f ../security/k8s/mongo-secret.yaml
kubectl apply -f ../security/k8s/deployment.yaml
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
kubectl apply -f ../security/k8s/service.yaml

kubectl get pods -n klovercloud

