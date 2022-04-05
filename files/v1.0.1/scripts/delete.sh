#!/bin/sh
kubectl delete statefulsets mongod -n klovercloud
kubectl delete services mongodb-service -n klovercloud
sleep 5
kubectl delete persistentvolumeclaims -l role=mongo -n klovercloud

#deleting tekton pipeline
kubectl delete --filename https://storage.googleapis.com/tekton-releases/pipeline/previous/v0.24.0/release.yaml

# deleting event-bank
kubectl delete -f files/v1.0.0/k8s/descriptors/2.configmap.yaml
kubectl delete -f files/v1.0.0/k8s/descriptors/3.mongo-secret.yaml
kubectl delete -f files/v1.0.0/k8s/descriptors/4.deployment.yaml
kubectl delete -f files/v1.0.0/k8s/descriptors/18.service.yaml


# deleting api-service
kubectl delete -f files/v1.0.0/k8s/descriptors/5.configmap.yaml
kubectl delete -f files/v1.0.0/k8s/descriptors/6.deployment.yaml
kubectl delete -f files/v1.0.0/k8s/descriptors/19.service.yaml


# deleting klovercloud-ci-integration-manager
kubectl delete -f files/v1.0.0/k8s/descriptors/7.configmap.yaml
kubectl delete -f files/v1.0.0/k8s/descriptors/8.mongo-secret.yaml
kubectl delete -f files/v1.0.0/k8s/descriptors/9.deployment.yaml
kubectl delete -f files/v1.0.0/k8s/descriptors/20.service.yaml


# deleting ci-core
kubectl delete -f files/v1.0.0/k8s/rbac/1.cluster-role.yaml
kubectl delete -f files/v1.0.0/k8s/rbac/2.service-account.yaml
kubectl delete -f files/v1.0.0/k8s/rbac/3.cluster-rolebinding.yaml
kubectl delete -f files/v1.0.0/k8s/descriptors/10.configmap.yaml
kubectl delete -f files/v1.0.0/k8s/descriptors/11.mongo-secret.yaml
kubectl delete -f files/v1.0.0/k8s/descriptors/12.deployment.yaml
kubectl delete -f files/v1.0.0/k8s/descriptors/21.service.yaml

# deleting ci-agent
kubectl delete -f files/v1.0.0/k8s/rbac/4.cluster-role.yaml
kubectl delete -f files/v1.0.0/k8s/rbac/5.service-account.yaml
kubectl delete -f files/v1.0.0/k8s/rbac/6.cluster-rolebinding.yaml
kubectl delete -f files/v1.0.0/k8s/descriptors/13.configmap.yaml
kubectl delete -f files/v1.0.0/k8s/descriptors/14.deployment.yaml
kubectl delete -f files/v1.0.0/k8s/descriptors/22.service.yaml


# deleting security
kubectl delete -f files/v1.0.0/k8s/descriptors/15.configmap.yml
kubectl delete -f files/v1.0.0/k8s/descriptors/16.mongo-secret.yml
kubectl delete -f files/v1.0.0/k8s/descriptors/17.deployment.yaml
kubectl delete -f files/v1.0.0/k8s/descriptors/23.service.yaml

kubectl get pods -n klovercloud