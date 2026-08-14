variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "cluster"
}

variable "frontend_repo_name" {
  description = "Name of the ECR repository for the frontend"
  type        = string
  default     = "mp-frontend"
}

variable "backend_repo_name" {
  description = "Name of the ECR repository for the backend"
  type        = string
  default     = "mp-backend"
}

variable "node_instance_type" {
  description = "EC2 instance type for the EKS worker nodes"
  type        = string
  default     = "t3.medium"
}
