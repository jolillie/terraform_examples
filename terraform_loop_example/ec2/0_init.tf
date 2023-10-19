# Provider Information
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.6"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "16.4.1"
    }
  }
  required_version = ">= 0.13"
}

provider "aws" {}

# Data lookups
# VPC
data "aws_vpc" "this" {
  filter {
    name   = "tag-key"
    values = var.vpc_lookup_tag_key
  }
  filter {
    name   = "tag-value"
    values = ["${var.vpc_lookup_tag_value}"]
  }
}

# Subnets
data "aws_subnets" "pub" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
  filter {
    name   = "tag-key"
    values = var.pub_subnet_lookup_tag_key
  }
  filter {
    name   = "tag-value"
    values = var.pub_subnet_lookup_tag_value
  }
}


# Variables
variable "vpc_lookup_tag_key" {
  description = "VPC Lookup Tag Key"
  type        = list(string)
  default     = ""
}

variable "vpc_lookup_tag_value" {
  description = "VPC Lookup Tag Value"
  type        = list(string)
  default     = ""
}

variable "pub_subnet_lookup_tag_key" {
  description = "Private Subnet Lookup Tag Key"
  type        = list(string)
  default     = ""
}

variable "pub_subnet_lookup_tag_value" {
  description = "Name of Private Security Group Rules Configuration File"
  type        = list(string)
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
  type        = number
  default     = 1
}
