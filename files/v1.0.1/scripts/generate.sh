#!/bin/sh
mongo_server=""
mongo_port=""
mongo_username=""
mongo_password=""
USER_FIRST_NAME=""
USER_LAST_NAME=""
USER_EMAIL=""
USER_PASSWORD=""
USER_PHONE=""
COMPANY_NAME=""
version=v1.0.1
kubectl apply -f files/$version/k8s/descriptors/1.namespace.yaml
echo "Want local Db? [Y/N]"
read n
if [ "$n" = "Y" ]
then
  TMPFILE=$(mktemp)
      /usr/bin/openssl rand -base64 741 > $TMPFILE
      kubectl create secret generic shared-bootstrap-data --from-file=internal-auth-mongodb-keyfile=$TMPFILE -n klovercloud
      rm $TMPFILE

      # Create mongodb service with mongod stateful-set
      # TODO: Temporarily added no-valudate due to k8s 1.8 bug: https://github.com/kubernetes/kubernetes/issues/53309
      kubectl apply -f files/$version/k8s/descriptors/db/mongo/mongo-deploy.yaml --validate=false
      sleep 5

      # Check deployment rollout status every 5 seconds (max 5 minutes) until complete.
      ATTEMPTS=0
      # shellcheck disable=SC2027
      ROLLOUT_STATUS_CMD="kubectl rollout status statefulSet/mongod -n klovercloud"
      until $ROLLOUT_STATUS_CMD || [ $ATTEMPTS -eq 60 ]; do
        $ROLLOUT_STATUS_CMD
        # shellcheck disable=SC2154
        ATTEMPTS=$((attempts + 1))
        sleep 5
      done


      mongo_server="\"mongod-0.mongodb-service.klovercloud.svc.cluster.local\""
      mongo_port="\"27017\""
      mongo_username="\"admin\""
      mongo_password="\"admin123\""
else
  read -p "Enter mongo server:" mongo_server
  read -p "Enter mongo port:" mongo_port
  read -p "Enter your mongo username:" mongo_username
  read -p "Enter your mongo password:" mongo_password

fi

echo "Want Register Admin? [Y/N]"
read m
if [ "$m" = "Y" ]
then
  read -p "Enter your first name:" USER_FIRST_NAME
  read -p "Enter your last name:" USER_LAST_NAME
  read -p "Enter your email:" USER_EMAIL
  read -p "Enter your password:" USER_PASSWORD
  read -p "Enter your phone:" USER_PHONE
  read -p "Enter your company name:" COMPANY_NAME

  sed -i "/^\([[:space:]]*USER_FIRST_NAME: \).*/s//\1$USER_FIRST_NAME/" files/$version/k8s/descriptors/security-server-configmap.yml
  sed -i "/^\([[:space:]]*USER_LAST_NAME: \).*/s//\1$USER_LAST_NAME/" files/$version/k8s/descriptors/security-server-configmap.yml
  sed -i "/^\([[:space:]]*USER_EMAIL: \).*/s//\1$USER_EMAIL/" files/$version/k8s/descriptors/security-server-configmap.yml
  sed -i "/^\([[:space:]]*USER_PASSWORD: \).*/s//\1$USER_PASSWORD/" files/$version/k8s/descriptors/security-server-configmap.yml
  sed -i "/^\([[:space:]]*USER_PHONE: \).*/s//\1$USER_PHONE/" files/$version/k8s/descriptors/security-server-configmap.yml
  sed -i "/^\([[:space:]]*COMPANY_NAME: \).*/s//\1$COMPANY_NAME/" files/$version/k8s/descriptors/security-server-configmap.yml

fi

#deploying tekton pipeline version: v0.15.0
kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml

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
sed -i "/^\([[:space:]]*MONGO_SERVER: \).*/s//\1$mongo_server/" files/$version/k8s/descriptors/event-bank-configmap.yaml
sed -i "/^\([[:space:]]*MONGO_PORT: \).*/s//\1$mongo_port/" files/$version/k8s/descriptors/event-bank-configmap.yaml
kubectl apply -f files/$version/k8s/descriptors/event-bank-configmap.yaml
sed -i "/^\([[:space:]]*MONGO_USERNAME: \).*/s//\1$mongo_username/" files/$version/k8s/descriptors/event-bank-mongo-secret.yaml
sed -i "/^\([[:space:]]*MONGO_PASSWORD: \).*/s//\1$mongo_password/" files/$version/k8s/descriptors/event-bank-mongo-secret.yaml
kubectl apply -f files/$version/k8s/descriptors/event-bank-mongo-secret.yaml
kubectl apply -f files/$version/k8s/descriptors/event-bank-deployment.yaml

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
kubectl apply -f files/$version/k8s/descriptors/event-bank-service.yaml


# deploying api-service
kubectl apply -f files/$version/k8s/descriptors/api-service-configmap.yaml
kubectl apply -f files/$version/k8s/descriptors/api-service-deployment.yaml
# Check deployment rollout status every 5 seconds (max 5 minutes) until complete.
ATTEMPTS=0
ROLLOUT_STATUS_CMD="kubectl rollout status deployment/klovercloud-api-service -n klovercloud"
until $ROLLOUT_STATUS_CMD || [ $ATTEMPTS -eq 60 ]; do
  $ROLLOUT_STATUS_CMD
  # shellcheck disable=SC2154
  ATTEMPTS=$((attempts + 1))
  sleep 5
done
kubectl apply -f files/$version/k8s/descriptors/api-service-service.yaml


# deploying klovercloud-ci-integration-manager
sed -i "/^\([[:space:]]*MONGO_SERVER: \).*/s//\1$mongo_server/" files/$version/k8s/descriptors/integration-manager-configmap.yaml
sed -i "/^\([[:space:]]*MONGO_PORT: \).*/s//\1$mongo_port/" files/$version/k8s/descriptors/integration-manager-configmap.yaml
kubectl apply -f files/$version/k8s/descriptors/integration-manager-configmap.yaml
sed -i "/^\([[:space:]]*MONGO_USERNAME: \).*/s//\1$mongo_username/" files/$version/k8s/descriptors/integration-manager-mongo-secret.yaml
sed -i "/^\([[:space:]]*MONGO_PASSWORD: \).*/s//\1$mongo_password/" files/$version/k8s/descriptors/integration-manager-mongo-secret.yaml
kubectl apply -f files/$version/k8s/descriptors/integration-manager-mongo-secret.yaml
kubectl apply -f files/$version/k8s/descriptors/integration-manager-deployment.yaml
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
kubectl apply -f files/$version/k8s/descriptors/integration-manager-service.yaml


# deploying ci-core
kubectl apply -f files/$version/k8s/rbac/core-engine-cluster-role.yaml
kubectl apply -f files/$version/k8s/rbac/core-engine-service-account.yaml
kubectl apply -f files/$version/k8s/rbac/core-engine-cluster-rolebinding.yaml
sed -i "/^\([[:space:]]*MONGO_SERVER: \).*/s//\1$mongo_server/" files/$version/k8s/descriptors/core-engine-configmap.yaml
sed -i "/^\([[:space:]]*MONGO_PORT: \).*/s//\1$mongo_port/" files/$version/k8s/descriptors/core-engine-configmap.yaml
kubectl apply -f files/$version/k8s/descriptors/core-engine-configmap.yaml
sed -i "/^\([[:space:]]*MONGO_USERNAME: \).*/s//\1$mongo_username/" files/$version/k8s/descriptors/core-engine-mongo-secret.yaml
sed -i "/^\([[:space:]]*MONGO_PASSWORD: \).*/s//\1$mongo_password/" files/$version/k8s/descriptors/core-engine-mongo-secret.yaml
kubectl apply -f files/$version/k8s/descriptors/core-engine-mongo-secret.yaml
kubectl apply -f files/$version/k8s/descriptors/core-engine-deployment.yaml
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
kubectl apply -f files/$version/k8s/descriptors/core-engine-service.yaml

# deploying ci-agent
kubectl apply -f files/$version/k8s/rbac/agent-cluster-role.yaml
kubectl apply -f files/$version/k8s/rbac/agent-service-account.yaml
kubectl apply -f files/$version/k8s/rbac/agent-cluster-rolebinding.yaml
kubectl apply -f files/$version/k8s/descriptors/agent-configmap.yaml
kubectl apply -f files/$version/k8s/descriptors/agent-deployment.yaml
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
kubectl apply -f files/$version/k8s/descriptors/agent-service.yaml


# deploying security
sed -i "/^\([[:space:]]*MONGO_SERVER: \).*/s//\1$mongo_server/" files/$version/k8s/descriptors/security-server-configmap.yml
sed -i "/^\([[:space:]]*MONGO_PORT: \).*/s//\1$mongo_port/" files/$version/k8s/descriptors/security-server-configmap.yml
kubectl apply -f files/$version/k8s/descriptors/security-server-configmap.yml
sed -i "/^\([[:space:]]*MONGO_USERNAME: \).*/s//\1$mongo_username/" files/$version/k8s/descriptors/security-server-mongo-secret.yml
sed -i "/^\([[:space:]]*MONGO_PASSWORD: \).*/s//\1$mongo_password/" files/$version/k8s/descriptors/security-server-mongo-secret.yml
kubectl apply -f files/$version/k8s/descriptors/security-server-mongo-secret.yml
kubectl apply -f files/$version/k8s/descriptors/security-server-deployment.yaml

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

kubectl apply -f files/$version/k8s/descriptors/security-server-service.yaml

kubectl get pods -n klovercloud
