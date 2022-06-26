#!/bin/bash
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
version=v0.0.1-beta

kubectl apply -f files/$version/k8s/descriptors/namespace.yaml
rm -rf files/$version/k8s/descriptors/temp
mkdir files/$version/k8s/descriptors/temp

echo "Want local Db? [Y/N]"
read n
if [ "$n" = "Y" ]; then
  TMPFILE=$(mktemp)
  /usr/bin/openssl rand -base64 741 >$TMPFILE
  kubectl create secret generic shared-bootstrap-data --from-file=internal-auth-mongodb-keyfile=$TMPFILE -n klovercloud
  rm $TMPFILE

  # Create mongodb service with mongod stateful-set
  # TODO: Temporarily added no-validate due to k8s 1.8 bug: https://github.com/kubernetes/kubernetes/issues/53309
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
  read -s -p "Enter your password: " mongo_password
  echo "/n"

  # editing mongo-secret.yaml
  sed -e 's@${mongo_username}@'"$mongo_username"'@g' -e 's@${mongo_password}@'"$mongo_password"'@g' <"files/$version/k8s/descriptors/mongo-secret.yaml" \
    >files/$version/k8s/descriptors/temp/temp-mongo-secret.yaml

  # editing event-bank descriptor
  sed -e 's@${mongo_server}@'"$mongo_server"'@g' -e 's@${mongo_port}@'"$mongo_port"'@g' <"files/$version/k8s/descriptors/event-bank-configmap.yaml" \
    >files/$version/k8s/descriptors/temp/temp-event-bank-configmap.yaml

  # editing klovercloud-ci-integration-manager descriptor
  sed -e 's@${mongo_server}@'"$mongo_server"'@g' -e 's@${mongo_port}@'"$mongo_port"'@g' <"files/$version/k8s/descriptors/integration-manager-configmap.yaml" \
    >files/$version/k8s/descriptors/temp/temp-integration-manager-configmap.yaml

  # editing core-engine descriptor
  sed -e 's@${mongo_server}@'"$mongo_server"'@g' -e 's@${mongo_port}@'"$mongo_port"'@g' <"files/$version/k8s/descriptors/core-engine-configmap.yaml" \
    >files/$version/k8s/descriptors/temp/temp-core-engine-configmap.yaml

  #editing security descriptor
  sed -e 's@${mongo_server}@'"$mongo_server"'@g' -e 's@${mongo_port}@'"$mongo_port"'@g' <"files/$version/k8s/descriptors/security-server-configmap.yml" \
    >files/$version/k8s/descriptors/temp/temp-security-server-configmap.yml

  #editing lightHouseCommand descriptor
  sed -e 's@${mongo_server}@'"$mongo_server"'@g' -e 's@${mongo_port}@'"$mongo_port"'@g' <"files/$version/k8s/descriptors/light-house-command-configmap.yml" \
    >files/$version/k8s/descriptors/temp/temp-light-house-command-configmap.yml

  #editing lightHouseQuery descriptor
  sed -e 's@${mongo_server}@'"$mongo_server"'@g' -e 's@${mongo_port}@'"$mongo_port"'@g' <"files/$version/k8s/descriptors/light-house-query-configmap.yml" \
    >files/$version/k8s/descriptors/temp/temp-light-house-query-configmap.yml

  kubectl apply -f files/$version/k8s/descriptors/temp/temp-mongo-secret.yaml

fi

read -p "Enter your first name:" USER_FIRST_NAME
read -p "Enter your last name:" USER_LAST_NAME
read -p "Enter your email:" USER_EMAIL
while true; do
  read -s -p "Enter your password: " USER_PASSWORD
  echo
  read -s -p "Confirm password: " USER_PASSWORD2
  echo
  [ "$USER_PASSWORD" = "$USER_PASSWORD2" ] && break
  echo "Password does not match.Please try again"
done
read -p "Do you want to enter your company name & phone number? [Y/N]" m
if [ "$m" = "Y" ]; then
  read -p "Enter your phone:" USER_PHONE
  read -p "Enter your company name:" COMPANY_NAME
else
  USER_PHONE=""
  COMPANY_NAME="default"
fi

echo "Want Light house? [Y/N]"
read lightHouseFlag


sed -e 's@${user_first_name}@'"$USER_FIRST_NAME"'@g' -e 's@${user_last_name}@'"$USER_LAST_NAME"'@g' -e "s|user_email|${USER_EMAIL}|g" -e 's@${user_phone}@'"$USER_PHONE"'@g' -e 's@${user_password}@'"$USER_PASSWORD"'@g' -e 's@${company_name}@'"$COMPANY_NAME"'@g' files/$version/k8s/descriptors/temp/temp-security-server-configmap.yml >files/$version/k8s/descriptors/temp/temp.yml; mv files/$version/k8s/descriptors/temp/temp.yml files/$version/k8s/descriptors/temp/temp-security-server-configmap.yml


#deploying tekton pipeline version: v0.15.0
kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/previous/v0.34.1/release.yaml

ATTEMPTS=0
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

#deploying event bank
kubectl apply -f files/$version/k8s/descriptors/temp/temp-event-bank-configmap.yaml
sed -e 's@${version}@'"$version"'@g' -e 's@${version}@'"$version"'@g' <"files/$version/k8s/descriptors/event-bank-deployment.yaml" \
    >files/$version/k8s/descriptors/temp/temp-event-bank-deployment.yaml
kubectl apply -f files/$version/k8s/descriptors/temp/temp-event-bank-deployment.yaml

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
sed -e 's@${version}@'"$version"'@g' -e 's@${version}@'"$version"'@g' <"files/$version/k8s/descriptors/api-service-deployment.yaml" \
    >files/$version/k8s/descriptors/temp/temp-api-service-deployment.yaml
kubectl apply -f files/$version/k8s/descriptors/temp/temp-api-service-deployment.yaml
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

# deploying klovercloud-ci-integration-manager\
kubectl apply -f files/$version/k8s/descriptors/temp/temp-integration-manager-configmap.yaml
sed -e 's@${version}@'"$version"'@g' -e 's@${version}@'"$version"'@g' <"files/$version/k8s/descriptors/integration-manager-deployment.yaml" \
    >files/$version/k8s/descriptors/temp/temp-integration-manager-deployment.yaml
kubectl apply -f files/$version/k8s/descriptors/temp/temp-integration-manager-deployment.yaml
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
kubectl apply -f files/$version/k8s/descriptors/temp/temp-core-engine-configmap.yaml
sed -e 's@${version}@'"$version"'@g' -e 's@${version}@'"$version"'@g' <"files/$version/k8s/descriptors/core-engine-deployment.yaml" \
    >files/$version/k8s/descriptors/temp/temp-core-engine-deployment.yaml
kubectl apply -f files/$version/k8s/descriptors/temp/temp-core-engine-deployment.yaml
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
if [ "$lightHouseFlag" = "Y" ]; then
  lighthouseBool="true"
  sed -e 's@${LIGHTHOUSE_ENABLED}@'"$lighthouseBool"'@g' <"files/$version/k8s/descriptors/agent-configmap.yaml" \
    >files/$version/k8s/descriptors/temp/temp-agent-configmap.yaml
  kubectl apply -f files/$version/k8s/descriptors/temp/temp-agent-configmap.yaml
else
  lighthouseBool="false"
  sed -e 's@${LIGHTHOUSE_ENABLED}@'"$lighthouseBool"'@g' <"files/$version/k8s/descriptors/agent-configmap.yaml" \
      >files/$version/k8s/descriptors/temp/temp-agent-configmap.yaml
  kubectl apply -f files/$version/k8s/descriptors/temp/temp-agent-configmap.yaml
fi
sed -e 's@${version}@'"$version"'@g' -e 's@${version}@'"$version"'@g' <"files/$version/k8s/descriptors/agent-deployment.yaml" \
    >files/$version/k8s/descriptors/temp/temp-agent-deployment.yaml
kubectl apply -f files/$version/k8s/descriptors/temp/temp-agent-deployment.yaml
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
kubectl apply -f files/$version/k8s/descriptors/temp/temp-security-server-configmap.yml
sed -e 's@${version}@'"$version"'@g' -e 's@${version}@'"$version"'@g' <"files/$version/k8s/descriptors/security-server-deployment.yaml" \
    >files/$version/k8s/descriptors/temp/temp-security-server-deployment.yaml
kubectl apply -f files/$version/k8s/descriptors/temp/temp-security-server-deployment.yaml

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

if [ "$lightHouseFlag" = "Y" ]; then
  kubectl apply -f files/$version/k8s/descriptors/temp/temp-light-house-command-configmap.yml
  sed -e 's@${version}@'"$version"'@g' -e 's@${version}@'"$version"'@g' <"files/$version/k8s/descriptors/light-house-command-deployment.yml" \
      >files/$version/k8s/descriptors/temp/temp-light-house-command-deployment.yml
  kubectl apply -f files/$version/k8s/descriptors/temp/temp-light-house-command-deployment.yml
  # Check deployment rollout status every 5 seconds (max 5 minutes) until complete.
  ATTEMPTS=0
  # shellcheck disable=SC2027
  ROLLOUT_STATUS_CMD="kubectl rollout status deployment/klovercloud-ci-light-house-command -n klovercloud"
  until $ROLLOUT_STATUS_CMD || [ $ATTEMPTS -eq 60 ]; do
    $ROLLOUT_STATUS_CMD
    # shellcheck disable=SC2154
    ATTEMPTS=$((attempts + 1))
    sleep 5
  done
  kubectl apply -f files/$version/k8s/descriptors/light-house-command-service.yml

  kubectl apply -f files/$version/k8s/descriptors/temp/temp-light-house-query-configmap.yml
  sed -e 's@${version}@'"$version"'@g' -e 's@${version}@'"$version"'@g' <"files/$version/k8s/descriptors/light-house-query-deployment.yml" \
     >files/$version/k8s/descriptors/temp/temp-light-house-query-deployment.yml
  kubectl apply -f files/$version/k8s/descriptors/temp/temp-light-house-query-deployment.yml
  # Check deployment rollout status every 5 seconds (max 5 minutes) until complete.
  ATTEMPTS=0
  # shellcheck disable=SC2027
  ROLLOUT_STATUS_CMD="kubectl rollout status deployment/klovercloud-ci-light-house-query -n klovercloud"
  until $ROLLOUT_STATUS_CMD || [ $ATTEMPTS -eq 60 ]; do
    $ROLLOUT_STATUS_CMD
    # shellcheck disable=SC2154
    ATTEMPTS=$((attempts + 1))
    sleep 5
  done
  kubectl apply -f files/$version/k8s/descriptors/light-house-query-service.yml
fi


kubectl get pods -n klovercloud
