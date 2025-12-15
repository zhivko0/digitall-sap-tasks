Bash script that checks SSL certificate expiration dates for a list of websites.

## Features

- Reads sites from config file
- Shows days until expiry with color-coded output
- Configurable warning/critical thresholds
- Optional Slack notifications
- Runs in Docker/Kubernetes

### Local Run

```bash
# edit sites.conf with your domains
./check_certs.sh
```

### Docker

```bash
# build
docker build -t cert-checker:latest .

# run with local config
docker run --rm -v $(pwd)/sites.conf:/etc/cert-checker/sites.conf cert-checker:latest
```

### Kubernetes (minikube)

```bash
# start minikube
minikube start --force

# build image in minikube's docker
eval $(minikube docker-env)
docker build -t cert-checker:latest .

# deploy
kubectl apply -f k8s/manifests.yaml

# run test job
kubectl -n cert-checker logs job/cert-checker-test -f

# check cronjob
kubectl -n cert-checker get cronjobs
```

## Config File Format

```
# comments start with #
google.com
github.com
mysite.com:8443
```
