aws_region       = "eu-central-1"
project_name     = "digitall-sap-demo"
instance_type    = "t3.micro"
web_server_count = 2
key_pair_name    = "digitall-sap-key"
ssh_allowed_cidr = ["0.0.0.0/0"]

db_instance_class = "db.t3.micro"
db_name           = "appdb"
db_username       = "dbadmin"
db_password       = "YourSecurePassword123!"
db_multi_az       = false # true for HA
