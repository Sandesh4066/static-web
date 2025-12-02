resource "aws_security_group" "static_site_sg" {
  name        = "static-site-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "StaticSiteSG"
  }
}

resource "aws_instance" "resume_server" {
  ami                         = "ami-0a0f1259dd1c90938"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_a.id
  vpc_security_group_ids      = [aws_security_group.static_site_sg.id]
  associate_public_ip_address = true
  key_name                    = "sandesh"

  user_data = <<-EOF
#!/bin/bash
yum update -y
amazon-linux-extras install nginx1 -y
systemctl enable nginx
systemctl start nginx

cat << 'EOF2' > /usr/share/nginx/html/index.html
<!DOCTYPE html>
<html>
<head><title>Sandesh Resume</title></head>
<body>
  <h1>Sandesh Pawar</h1>
  <p>BTech CSE | Cloud Computing | AWS | DevOps</p>
</body>
</html>
EOF2
EOF

  tags = {
    Name = "Resume-Website-EC2"
  }
}

output "website_url" {
  value = "http://${aws_instance.resume_server.public_ip}"
}
