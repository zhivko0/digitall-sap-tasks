# SSL Certificate Expiry Checker

Bash script that checks SSL certificate expiration dates for a list of websites.

## Features

- Reads sites from config file
- Shows days until expiry with color-coded output
- Configurable warning/critical thresholds
- Optional Slack notifications
- Runs in Docker/Kubernetes

## Quick Start

### Local Run

```bash
# edit sites.conf with your domains
./check_certs.sh
```

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| CONFIG_FILE | /etc/cert-checker/sites.conf | Path to sites config |
| WARN_DAYS | 30 | Warning threshold |
| CRIT_DAYS | 7 | Critical threshold |
| SLACK_WEBHOOK | - | Slack webhook URL (optional) |

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
minikube start

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

## Output Example

```
[OK] google.com - expires in 67 days (2025-03-15 12:00:00)
[WARN] staging.example.com - expires in 25 days (2025-02-01 00:00:00)
[ERROR] old.example.com - expires in 3 days (2025-01-10 00:00:00)
```
