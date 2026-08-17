# STEP 2c: One EC2 instance to host Jenkins, Nexus, Docker.
# Ansible configures this box in the next phase.

resource "aws_security_group" "cicd_sg" {
  name        = "${var.project_name}-cicd-sg"
  description = "Jenkins/Nexus/Grafana access"
  vpc_id      = module.vpc.vpc_id

  ingress { # SSH
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # tighten to your IP in production
  }
  ingress { # Jenkins
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress { # Nexus
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress { # Grafana
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "cicd_server" {
  ami                    = "ami-0c101f26f147fa7fd" # Ubuntu 22.04 LTS, us-east-1 - check latest for your region
  instance_type          = var.cicd_instance_type
  subnet_id              = module.vpc.public_subnets[0]
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.cicd_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "${var.project_name}-cicd-server"
    Role = "jenkins-nexus-docker"
  }
}
