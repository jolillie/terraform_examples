#========== Security Groups ==========#

module "server_sg_private" {
  # Docs: https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/5.1.0
  source = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name        = "private-servers"
  description = "Security group for user-service with custom ports open within VPC, and PostgreSQL publicly open"
  vpc_id      = "${data.aws_vpc.this.id}"

  ingress_cidr_blocks      = ["10.0.0.0/16"]
  ingress_rules            = ["https-443-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8090
      protocol    = "tcp"
      description = "User-service ports"
      cidr_blocks = "10.0.0.0/16"
    },
    {
      rule        = "postgresql-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}

module "server_sg_public" {
  # Docs: https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/5.1.0
  source = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name        = "public-servers"
  description = "Security group for user-service with custom ports open within VPC, and PostgreSQL publicly open"
  vpc_id      = "${data.aws_vpc.this.id}"

  ingress_cidr_blocks      = ["10.0.0.0/16"]
  ingress_rules            = ["https-443-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8090
      protocol    = "tcp"
      description = "User-service ports"
      cidr_blocks = "10.0.0.0/16"
    },
    {
      rule        = "postgresql-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}

#========== EC2 Instance ==========#

module "ec2_instance_private" {
  # Docs: https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws/5.5.0
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.5.0"
  for_each = local.yml_priv_servers.servers
  name = each.key

  instance_type          = each.value.instance_type
  key_name               = each.value.key_name
  monitoring             = local.yml_priv_servers.monitoring
  #monitoring             = each.value.monitoring # Example is to show that you can manage these values in different ways
  vpc_security_group_ids = ["${module.server_sg_private.security_group_id}"]
  subnet_id              = "${data.aws_subnets.priv.ids[0]}"

  tags = "${each.value.tags}"
}



module "ec2_instance_public" {
  # Docs: https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws/5.5.0
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.5.0"
  count = length(var.pub_servers)
  name = var.pub_servers[count.index].name
  instance_type          = var.pub_servers[count.index].instance_type
  key_name               = var.pub_servers[count.index].key_name
  monitoring             = var.pub_servers[count.index].monitoring
  vpc_security_group_ids = ["${module.server_sg_public.security_group_id}"]
  subnet_id              = "${data.aws_subnets.pub.ids[0]}"

  tags = "${var.pub_servers[count.index].tags}"
}

module "ec2_instance_public_count" {
  # Docs: https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws/5.5.0
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.5.0"
  count = var.num_pub_servers
  name = "${var.pub_servers_standard.name}_${count.index}"
  instance_type          = var.pub_servers_standard.instance_type
  key_name               = var.pub_servers_standard.key_name
  monitoring             = var.pub_servers_standard.monitoring
  vpc_security_group_ids = ["${module.server_sg_public.security_group_id}"]
  subnet_id              = "${data.aws_subnets.pub.ids[0]}"

  tags = "${var.pub_servers_standard.tags}"
}
