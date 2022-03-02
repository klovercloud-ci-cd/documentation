## Ngrok workaround 

- [Install](https://ngrok.com/docs/ngrok-link)
- Expose server on the forwarded port of api service. In our installation, api service port is 80.
- You can forward port using the following command:
```couchbasequery
kubectl port-forward --address yourIP svc/klovercloud-api-service 4100:80 -n klovercloud
```
- Run the following command
```couchbasequery
ngrok http yourIP:4100
```
- Copy the url. It will look like ```http://2339-180-210-178-26.ngrok.io```.