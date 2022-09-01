## Static Analycis
- SonarQube:


## Image Scaner
### Snyk:

To scan image add an intermediary step,
Example:
```yaml
- name: interstep #name of the step
  type: INTERMEDIARY #type of the step
  trigger: AUTO 
  params:
    env: test
    service_account: <service_account_name>  #Service account with mounted secrets
    revision: latest 
    images: 'quay.io/klovercloud/automation/klovercloud-snyk:v0.0.1'
    envs_from_configmaps: tekton/cm-test #ConfigMap that needed to mount to run the scanning
    
      
 ```
 
 Example of configMap:
 ```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: cm-test
  namespace: tekton
data:
  SNYK_TOKEN: <your snyk token> #snyk user token
  ORGANIZATION_ID: <your snyk organiztion id> #snyk organization id
  PROJECT_ID: <snyk project id> #snyk project id
  ALLOWED_ISSUES: "50" #how many issues want to allow
  IMAGE: <image> #image that want to scan
 
 ```
 [N:B:] In params we can also take input as ```key:value``` pair in ```envs:``` field. Example:
 ```yaml
  name: interstep #name of the step
  type: INTERMEDIARY #type of the step
  trigger: AUTO 
  params:
    env: test
    service_account: <service_account_name>  #Service account with mounted secrets
    revision: latest 
    images: 'quay.io/klovercloud/automation/klovercloud-snyk:v0.0.1'
    envs: SNYK_TOKEN: <your snyk token>, ORGANIZATION_ID: <your snyk organiztion id>
 ```
