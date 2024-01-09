# IaC for National Transfer Microservices project using terraform 

1. create a service principal with owner role
2. copy the .env.example to .env
```bash
    cp .env.example .env
```
3. add the env variables you got from creating the service principal in .env
4. run:
```bash
    export $(xargs < .env)
```
5. run the backend.sh to create a storage account and a container to store the tfstate
```bash
    ./backend.sh
```

6. create an argo-github-secret.yml at argocd_manifests :
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-private-ssh-repo
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  url: ssh://git@github.com/argoproj/argocd-example-apps
  sshPrivateKey: |
    -----BEGIN OPENSSH PRIVATE KEY-----
    ...
    -----END OPENSSH PRIVATE KEY-----
  insecure: "true"
```
