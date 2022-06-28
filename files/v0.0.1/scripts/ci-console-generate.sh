read -p "Enter your public api service base url:" apiServiceUrl
read -p "Enter your public Security service base url:" securityUrl
read -p "Enter your public webHook events service base url:" webhookEventUrl
version=v0.0.1

sed -e 's@${apiServiceUrl}@'"$apiServiceUrl"'@g' -e 's@${securityUrl}@'"$securityUrl"'@g' -e 's@${webhookEventUrl}@'"$webhookEventUrl"'@g' <"files/$version/k8s/descriptors/ci-console-descriptor.yml" \
  >files/$version/k8s/descriptors/temp/temp-ci-console-descriptor.yml

kubectl apply -f files/$version/k8s/descriptors/temp/temp-ci-console-descriptor.yml

sleep 10

# Check deployment rollout status every 5 seconds (max 5 minutes) until complete.
ATTEMPTS=0
# shellcheck disable=SC2027
ROLLOUT_STATUS_CMD="kubectl rollout status deployment/klovercloud-ci-console -n klovercloud"
until $ROLLOUT_STATUS_CMD || [ $ATTEMPTS -eq 60 ]; do
  $ROLLOUT_STATUS_CMD
  # shellcheck disable=SC2154
  ATTEMPTS=$((attempts + 1))
  sleep 5
done