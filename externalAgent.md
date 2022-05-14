To enable external agents, regenerate configmap of api-service:

Example:
```yml
apiVersion: v1
kind: ConfigMap
metadata:
  name: klovercloud-api-service-envar-config
  namespace: klovercloud
data:
  RUN_MODE: "PRODUCTION"
  SERVER_PORT: "8080"
  KLOVERCLOUD_CI_INTEGRATION_MANAGER_URL: "http://klovercloud-integration-manager.klovercloud.svc.cluster.local/api/v1"
  KLOVERCLOUD_CI_EVENT_STORE: "http://klovercloud-ci-event-bank.klovercloud.svc.cluster.local/api/v1"
  KLOVERCLOUD_CI_EVENT_STORE_WS: "ws://klovercloud-ci-event-bank.klovercloud.svc.cluster.local/api/v1"

  PUBLIC_KEY: "{PUBLIC_KEY}"

  ENABLE_AUTHENTICATION: "true"
  JAEGER_AGENT_HOST: "localhost"
  JAEGER_SAMPLER_TYPE: "const"
  JAEGER_SAMPLER_PARAM: "1"
  JAEGER_REPORTER_LOG_SPANS: "true"
  JAEGER_SERVICE_NAME: "api-service"
  ENABLE_OPENTRACING: "true"
  PRIVATE_KEY_FOR_INTERNAL_CALL: "{PRIVATE_KEY_FOR_INTERNAL_CALL}"
  PUBLIC_KEY_FOR_INTERNAL_CALL: "{PUBLIC_KEY_FOR_INTERNAL_CALL}"
```
To apply the configmap, run:
```
kubectl apply -f configmap.yaml
```
To restart the deployment, run:
```
kubectl rollout restart deployment/{deployment-name_of_api_service}
```
To execute the deployment, run:
```
kubectl exec -it {api service pod} -n {namespace_of_api_service} bash
```
To generate agent token, run:
```
kcpctl generate-jwt client={your agent name}
```
It will return a token, which you can use to authenticate with the API.
Example:
```
root@klovercloud-api-service-59b65595cf-n6qdx:/app# kcpctl generate-jwt client=local_agent 

token:  eyJhbGciOiJSUzUxMiIsInR5cCI6IkpXVCJ9.eyJkYXRhIjp7Im5hbWUiOiJsb2NhbCJ9LCJleHAiOjUyNTI1MjU4NDAsImlhdCI6MTY1MjUyNTg0MH0.iK2TuESPqeL8SAcnNN-BD_Iy3tLfEFybDW6YDpyvtlQsI5or8cMot_bUmI1iQMkM3Kag5pJ2RHm06w0qgAeLDY8KUGk7mIAWlo41Grdls8vTkyIoVeyE-LYR4tYefqoaP36eTs2tiumZyFmQ8htlWaLUUnUibqumfixu_4rqyxJvaRfTdDitd5dfQ_dqpsmgv18-EA4E1IygFsiqO3ju6PHHETPL41bhioUCBNIuJjt04g2cBQpIKU5ean75YbFRM5QAnlpQQXE-urmiT1_z0nSd_Diz10RLhSZqMaw9Ft1gLl3hkUkKfKifSWokOE9yNrt1j6NM0qwEfFwKwYGEF8DXTBiVmgCEP06DZKcTxj9I_edku2NzhRiOAtYh4zqN_i9VkeMndJGDRm8p29z9qjAr-0HsKetf0s4VwtypaqxGOd1d3wOJpsluEH7MmQMXgu-jmzdQk0yZUd8O3LmAUDsDg8Th6zBFY9U8QebZxQrlz-eiVJvXZqKjmcj2iuIjEod2MPcDGvfDM2wdh5QaABRuMSfIkX-82AZTEVcPjZAgtAeIZXToLxxdNWUqEzgOH0RNCt7c1-LVZ__9CPhz1Q3mXbDzrJ66t76KLQPk8c7gJtiqrj0iU74-dzO0Q9_mGNIsL1jhi6zuXRmywc8ka_D7FswiVbFCZYWd47yJ0vk

root@klovercloud-api-service-59b65595cf-n6qdx:/app#
```
Copy the token and regenerate the configmap of agent.
Example:
```yml
apiVersion: v1
kind: ConfigMap
metadata:
  name: klovercloud-ci-agent-envar-config
  namespace: klovercloud
data:
  IS_K8: "True"
  RUN_MODE: "PRODUCTION"
  SERVER_PORT: "8080"
  EVENT_STORE_URL: "http://klovercloud-ci-event-bank/api/v1"
  AGENT_NAME: "local_agent"
  PULL_SIZE: "4"
  PUBLIC_KEY: "{public key}"
  TOKEN: "{generated token}"
  ENABLE_AUTHENTICATION: "true"
```
To apply the configmap, run the following command:
```
kubectl apply -f klovercloud-ci-agent-envar-config.yaml
```
To restart the agent, run the following command:
```
kubectl rollout restart deployment/{deployment_name_of_agent} -n {namespace_of_agent}
```
