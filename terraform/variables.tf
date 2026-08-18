variable "aws_region" {
  default = "us-east-1"
}

variable "project_name" {
  default = "devops-pipeline"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "cicd_instance_type" {
  description = "EC2 instance for Jenkins/Nexus/Prometheus/Grafana"
  default     = "t3.small"
}

variable "key_pair_name" {
  description = "Existing EC2 key pair name for SSH access"
  type        = string
  default     = "devops-demo-key"
}
