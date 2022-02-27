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
```cmd
Cli to use klovercloud-ci apis!

Find more information at: https://github.com/klovercloud-ci-cd/ctl

Usage:
  ctl [command]

Available Commands:
  completion  Generate the autocompletion script for the specified shell
  describe    Describe resource [company/repository/application]
  help        Help about any command
  list        Describe resource [company/repository/application/process]
  login       Login using email and password
  logs        Get logs by process ID
  register    Register User
  trigger     Notify git
  update      Update resource [repository/application]

Flags:
  -h, --help      help for ctl
  -v, --version   version for ctl

Use "ctl [command] --help" for more information about a command.
```
Admin Registration using json or yaml file:
```couchbasequery
ctl register file={file_name}.json
```
File Example:
```couchbasequery
{
	"first_name": "Klovercloud",
	"last_name": "Admin",
	"email": "klovercloud.admin@klovercloud.com",
	"phone": "01xxxxxxxx",
	"auth_type": "password",
	"password": "adminabc"
}
```
Login:
```couchbasequery
ctl login option apiserver={apiServerUrl} option security={securityUrl}
```
```couchbasequery
Enter email: klovercloud.admin@klovercloud.com
Enter Password:
```
Attach Company:
```couchbasequery
ctl update user option=attach_company file={file}
```
Re-login:
```couchbasequery
ctl login option apiserver={apiServerUrl} option security={securityUrl}
```
```couchbasequery
Enter email: klovercloud.admin@klovercloud.com
Enter Password:
```
Repository Append:
```couchbasequery
ctl update repos file={file} option=APPEND_REPOSITORY
```
File Example:
```couchbasequery
{
  "repositories": [
    {
      "type": "GITHUB",
      "token": "abcde12345"
    }
  ]
}
```

Please follow [this](https://github.com/klovercloud-ci-cd/ctl) guide.
