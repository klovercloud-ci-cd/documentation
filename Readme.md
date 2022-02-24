## Architecture
Klovercloud ci manages company and repositories builds docker image from git, deploys and updates k8s resources, notifies observers, allows user to listen pipeline events and logs.
-  [Read more](https://github.com/klovercloud-ci-cd/architecture/blob/master/README.md)
## Installation guide
Clone:
```couchbasequery
git clone https://github.com/klovercloud-ci-cd/documentation.git
```
Set required version:
```couchbasequery
export KLOVERCLOUD_CI_VERSION=v1.0.0
```
Install klovercloud-ci:
```couchbasequery
./files/$KLOVERCLOUD_CI_VERSION/scripts/generate.sh
```
Provide mongo server url and port.

```Example:
Enter mongo server:"loaclhost"
Enter mongo port:"27017"
```

Database username and password.

```Example:
Enter your mongo username:"username"
Enter your mongo password:"password"
```
Check pods statues:

```couchbasequery
kubectl get pods -n klovercloud
```
Example of a successful installation: 

![context](files/images/deployStatusExample.png)


## Getting started
### Prerequisites:
- [Ctl Installation](https://github.com/klovercloud-ci-cd/ctl)

Login:
```couchbasequery
ctl login
```
Repository Append:
```couchbasequery
ctl update repos file={file_path} option=append
```

Please follow [this](https://github.com/klovercloud-ci-cd/ctl) guide.
