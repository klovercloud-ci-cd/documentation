For external agents we need security. So we need to generate new token for calling api services. We can generate token via api service and instructions are bellow.

Enable external agents, replace some values(ENABLE_AUTHENTICATION, PRIVATE_KEY_FOR_INTERNAL_CALL,PUBLIC_KEY_FOR_INTERNAL_CALL) of api service configmapconfigmap of api-service.

[N:B: PRIVATE_KEY_FOR_INTERNAL_CALL & PUBLIC_KEY_FOR_INTERNAL_CALL are the pair of RSA key pair.]

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
Apply the configmap, run:
```
kubectl apply -f configmap.yaml
```
Restart the deployment, run:
```
kubectl rollout restart deployment/{deployment-name_of_api_service}
```
Exec into api service pod, run:
```
kubectl exec -it {api service pod} -n {namespace_of_api_service} bash
```
Generate agent token, run:
```
kcpctl generate-jwt client={your agent name}
```
It will return a token, which you can use to authenticate with the API.
Example:
```
token:  eyJhbGciOiJSUzUxMiIsInR5cCI6IkpXVCJ9.eyJkYXRhIjp7Im5hbWUiOiJsb2NhbCJ9LCJleHAiOjUyNTI1MjU4NDAsImlhdCI6MTY1MjUyNTg0MH0.iK2TuESPqeL8SAcnNN-BD_Iy3tLfEFybDW6YDpyvtlQsI5or8cMot_bUmI1iQMkM3Kag5pJ2RHm06w0qgAeLDY8KUGk7mIAWlo41Grdls8vTkyIoVeyE-LYR4tYefqoaP36eTs2tiumZyFmQ8htlWaLUUnUibqumfixu_4rqyxJvaRfTdDitd5dfQ_dqpsmgv18-EA4E1IygFsiqO3ju6PHHETPL41bhioUCBNIuJjt04g2cBQpIKU5ean75YbFRM5QAnlpQQXE-urmiT1_z0nSd_Diz10RLhSZqMaw9Ft1gLl3hkUkKfKifSWokOE9yNrt1j6NM0qwEfFwKwYGEF8DXTBiVmgCEP06DZKcTxj9I_edku2NzhRiOAtYh4zqN_i9VkeMndJGDRm8p29z9qjAr-0HsKetf0s4VwtypaqxGOd1d3wOJpsluEH7MmQMXgu-jmzdQk0yZUd8O3LmAUDsDg8Th6zBFY9U8QebZxQrlz-eiVJvXZqKjmcj2iuIjEod2MPcDGvfDM2wdh5QaABRuMSfIkX-82AZTEVcPjZAgtAeIZXToLxxdNWUqEzgOH0RNCt7c1-LVZ__9CPhz1Q3mXbDzrJ66t76KLQPk8c7gJtiqrj0iU74-dzO0Q9_mGNIsL1jhi6zuXRmywc8ka_D7FswiVbFCZYWd47yJ0vk
```
Copy the token and replace the value "TOKEN" of agent configmap.
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
Apply the configmap, run the following command:
```
kubectl apply -f klovercloud-ci-agent-envar-config.yaml
```
Apply deployment.
Example:
```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: klovercloud-ci-agent
  namespace: klovercloud
spec:
  replicas: 1
  selector:
    matchLabels:
      app: klovercloud-ci-agent
  template:
    metadata:
      labels:
        app: klovercloud-ci-agent
    spec:
      terminationGracePeriodSeconds: 30
      containers:
        - name: app
          imagePullPolicy: Always
          image: { docker image of klovercloud-ci-agent }
          resources:
            limits:
              cpu: 100m
              memory: 256Mi
            requests:
              cpu: 100m
              memory: 256Mi
          envFrom:
            - configMapRef:
                name: klovercloud-ci-agent-envar-config
          ports:
            - containerPort: 8080
          readinessProbe:
            httpGet:
              path: /health
              port: 8080
            initialDelaySeconds: 30
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /health
              port: 8080
            initialDelaySeconds: 30
            periodSeconds: 10
      serviceAccountName: klovercloud-ci-agent-sa
```
Run the following command to apply the deployment:
```
kubectl apply -f klovercloud-ci-agent.yaml
```
Apply the service.
Example:
```yml
apiVersion: v1
kind: Service
metadata:
  name: klovercloud-ci-agent
  namespace: klovercloud
  labels:
    app: klovercloud-ci-agent
spec:
  ports:
  - name: http-rest
    port: 80
    targetPort: 8080
    protocol: TCP
  selector:
    app: klovercloud-ci-agent
```
Run the following command to apply the service:
```
kubectl apply -f klovercloud-ci-agent.yaml
```

We have enabled authentication, so we need authorization token for internal agent also.We have to generate token by following above steps and replace the value of "TOKEN" in agent configmap and have to roll out restart the deployment of internal agent.