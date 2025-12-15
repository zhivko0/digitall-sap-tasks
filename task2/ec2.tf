data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# EC2 instances
resource "aws_instance" "web" {
  count                  = var.web_server_count
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public[count.index % 2].id
  vpc_security_group_ids = [aws_security_group.web.id]
  key_name               = var.key_pair_name

  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    db_host     = aws_db_instance.main.address
    db_name     = var.db_name
    db_user     = var.db_username
    db_password = var.db_password
  }))

  tags = {
    Name = "${var.project_name}-web-${count.index + 1}"
  }

  depends_on = [aws_db_instance.main]
}
