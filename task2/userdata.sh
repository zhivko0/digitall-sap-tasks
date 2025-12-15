#!/bin/bash
set -e

# install nginx
yum update -y
yum install -y nginx postgresql15

systemctl enable nginx
systemctl start nginx

# create simple page showing instance info
cat > /usr/share/nginx/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head><title>Digitall SAP Demo</title></head>
<body>
<h1>Test</h1>
<p>Database host: ${db_host}</p>
<p>Database name: ${db_name}</p>
</body>
</html>
EOF
