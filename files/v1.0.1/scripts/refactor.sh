read -p "Enter your public api service base url:" url

github="${url}/api/v1/githubs"
bitbucket="${url}/api/v1/bitbuckets"
version=v1.0.1


sed -i 's#http://klovercloud-api-service/api/v1/githubs#'$github'#g' files/$version/k8s/descriptors/integration-manager-configmap.yaml
sed -i 's#http://klovercloud-api-service/api/v1/bitbuckets#'$bitbucket'#g' files/$version/k8s/descriptors/integration-manager-configmap.yaml

kubectl apply -f files/$version/k8s/descriptors/integration-manager-configmap.yaml
kubectl rollout restart deploy klovercloud-integration-manager -n klovercloud

sleep 10


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
