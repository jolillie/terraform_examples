# Provider Information
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.6"
    }
    gitlab = {
      source = "gitlabhq/gitlab"
      version = "16.4.1"
    }
  }
  required_version = ">= 0.13"
}

provider "aws" {}

provider "gitlab" {}


# Local Values
locals {
  yml_priv_servers = yamldecode(base64decode(data.gitlab_repository_file.priv_servers.content))
}


# Data lookups
# VPC
data "aws_vpc" "this" {
  filter {
    name = "tag-key"
    values = var.vpc_lookup_tag_key
  }
  filter {
    name = "tag-value"
    values = ["${var.vpc_lookup_tag_value}"]
  }
}

# Subnets
data "aws_subnets" "priv" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
  filter {
    name = "tag-key"
    values = var.priv_subnet_lookup_tag_key
  }
  filter {
    name = "tag-value"
    values = ["${var.priv_subnet_lookup_tag_value}"]
  }
}

data "aws_subnets" "pub" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
  filter {
    name = "tag-key"
    values = var.pub_subnet_lookup_tag_key
  }
  filter {
    name = "tag-value"
    values = ["${var.pub_subnet_lookup_tag_value}"]
  }
}


# Gitlab config files
data "gitlab_repository_file" "priv_servers" {
  project   = var.gitlab_project_id
  ref       = var.gitlab_project_branch
  file_path = var.priv_server_config_file
}


# Variables
variable "gitlab_token_name" {
  description = "Name of Gitlab Token stored in AWS Secrets Manager"
  type        = string
  default     = ""
}

variable "gitlab_project_id" {
  description = "ID of Project in Gitlab that has the config files"
  type        = string
  default     = ""
}

variable "gitlab_project_branch" {
  description = "Branch of the Project that we are using to pull config files"
  type        = string
  default     = ""
}

variable "priv_server_config_file" {
  description = "Name of Private Server Configuration File"
  type        = string
  default     = ""
}

variable "vpc_lookup_tag_key" {
  description = "Name of Private Security Group Rules Configuration File"
  type        = list(string)
  default     = ""
}

variable "vpc_lookup_tag_value" {
  description = "Name of Private Security Group Rules Configuration File"
  type        = string
  default     = ""
}

variable "priv_subnet_lookup_tag_key" {
  description = "Name of Private Security Group Rules Configuration File"
  type        = list(string)
  default     = ""
}

variable "priv_subnet_lookup_tag_value" {
  description = "Name of Private Security Group Rules Configuration File"
  type        = string
  default     = ""
}

variable "pub_subnet_lookup_tag_key" {
  description = "Name of Private Security Group Rules Configuration File"
  type        = list(string)
  default     = ""
}

variable "pub_subnet_lookup_tag_value" {
  description = "Name of Private Security Group Rules Configuration File"
  type        = string
  default     = ""
}

variable "pub_servers" {
  description = "List of public servers"
  type = list(object({
    name          = string
    instance_type = string
    key_name      = string
    monitoring    = bool
    tags          = map(string)
  }))
}

variable "pub_servers_standard" {
  description = "List of public servers"
  type = object({
    name          = string
    instance_type = string
    key_name      = string
    monitoring    = bool
    tags          = map(string)
  })
}

variable "num_pub_servers" {
  description = "Number of public servers to create"
  type = number
  default = 1
}
