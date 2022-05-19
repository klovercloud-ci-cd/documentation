read -p "Enter your public api service base url:" url

version=v0.0.1

sed -e 's@${api_service_base_url}@'"$url"'@g' files/$version/k8s/descriptors/temp/temp-integration-manager-configmap.yaml >files/$version/k8s/descriptors/temp/temp.yml; mv files/$version/k8s/descriptors/temp/temp.yml files/$version/k8s/descriptors/temp/temp-integration-manager-configmap.yaml

kubectl apply -f files/$version/k8s/descriptors/temp/temp-integration-manager-configmap.yaml
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
