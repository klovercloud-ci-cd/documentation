#!/bin/sh
version=v0.0.1
kubectl delete statefulsets mongod -n klovercloud
kubectl delete services mongodb-service -n klovercloud
sleep 5
kubectl delete persistentvolumeclaims -l role=mongo -n klovercloud

#deleting tekton pipeline
kubectl delete --filename https://storage.googleapis.com/tekton-releases/pipeline/previous/v0.24.0/release.yaml

kubectl delete -f files/$version/k8s/descriptors/temp/temp-mongo-secret.yaml

# deleting event-bank
kubectl delete -f files/$version/k8s/descriptors/temp/temp-event-bank-configmap.yaml
kubectl delete -f files/$version/k8s/descriptors/event-bank-deployment.yaml
kubectl delete -f files/$version/k8s/descriptors/event-bank-service.yaml


# deleting api-service
kubectl delete -f files/$version/k8s/descriptors/api-service-configmap.yaml
kubectl delete -f files/$version/k8s/descriptors/api-service-deployment.yaml
kubectl delete -f files/$version/k8s/descriptors/api-service-service.yaml


# deleting klovercloud-ci-integration-manager
kubectl delete -f files/$version/k8s/descriptors/temp/temp-integration-manager-configmap.yaml
kubectl delete -f files/$version/k8s/descriptors/integration-manager-deployment.yaml
kubectl delete -f files/$version/k8s/descriptors/integration-manager-service.yaml


# deleting ci-core
kubectl delete -f files/$version/k8s/rbac/core-engine-cluster-role.yaml
kubectl delete -f files/$version/k8s/rbac/core-engine-service-account.yaml
kubectl delete -f files/$version/k8s/rbac/core-engine-cluster-rolebinding.yaml
kubectl delete -f files/$version/k8s/descriptors/temp/temp-core-engine-configmap.yaml
kubectl delete -f files/$version/k8s/descriptors/core-engine-deployment.yaml
kubectl delete -f files/$version/k8s/descriptors/core-engine-service.yaml

# deleting ci-agent
kubectl delete -f files/$version/k8s/rbac/agent-cluster-role.yaml
kubectl delete -f files/$version/k8s/rbac/agent-service-account.yaml
kubectl delete -f files/$version/k8s/rbac/agent-cluster-rolebinding.yaml
kubectl delete -f files/$version/k8s/descriptors/agent-configmap.yaml
kubectl delete -f files/$version/k8s/descriptors/agent-deployment.yaml
kubectl delete -f files/$version/k8s/descriptors/agent-service.yaml


# deleting security
kubectl delete -f files/$version/k8s/descriptors/temp/temp-security-server-configmap.yml
kubectl delete -f files/$version/k8s/descriptors/security-server-deployment.yaml
kubectl delete -f files/$version/k8s/descriptors/security-server-service.yaml

kubectl get pods -n klovercloud