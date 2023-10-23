terraform {
  required_providers {
    port-labs = {
      source  = "port-labs/port-labs"
      version = "0.10.4"
    }
  }
}

data "aws_region" "current" {}

# Create Blueprints
resource "port-labs_blueprint" "region" {
  title      = "Region"
  icon       = "AWS"
  identifier = "region"

  properties {
    title      = "Link"
    identifier = "link"
    type       = "string"
    format     = "url"
  }
}

resource "port-labs_entity" "current_region" {
  identifier = data.aws_region.current.name
  title      = data.aws_region.current.name
  blueprint  = port-labs_blueprint.region.identifier
  properties {
    name  = "link"
    value = "https://${data.aws_region.current.name}.console.aws.amazon.com/"
  }
}


module "port_ssl_certificate" {
  source     = "../ssl_certificate"
  count      = contains(var.resources, "ssl_certificate") ? 1 : 0
  depends_on = [port-labs_blueprint.region]
}

module "port_cdn" {
  source     = "../cdn"
  count      = contains(var.resources, "cdn") ? 1 : 0
  depends_on = [port-labs_blueprint.region]
}

module "port_dynamodb_table" {
  source     = "../dynamodb_table"
  count      = contains(var.resources, "dynamodb_table") ? 1 : 0
  depends_on = [port-labs_blueprint.region]
}

module "port_ecs_service" {
  source     = "../ecs_service"
  count      = contains(var.resources, "ecs_service") ? 1 : 0
  depends_on = [port-labs_blueprint.region]
}

module "port_lambda_function" {
  source     = "../lambda"
  count      = contains(var.resources, "lambda") ? 1 : 0
  depends_on = [port-labs_blueprint.region]
}

module "port_rds_db_instance" {
  source     = "../rds_db_instance"
  count      = contains(var.resources, "rds_db_instance") ? 1 : 0
  depends_on = [port-labs_blueprint.region]
}

module "port_hosted_zone" {
  source     = "../hosted_zone"
  count      = contains(var.resources, "hosted_zone") ? 1 : 0
  depends_on = [port-labs_blueprint.region]
}

module "port_object_storage" {
  source     = "../object_storage"
  count      = contains(var.resources, "object_storage") ? 1 : 0
  depends_on = [port-labs_blueprint.region]
}

module "port_sqs" {
  source     = "../sqs"
  count      = contains(var.resources, "sqs") ? 1 : 0
  depends_on = [port-labs_blueprint.region]
}

module "port_sns" {
  source     = "../sns"
  count      = contains(var.resources, "sns") ? 1 : 0
  depends_on = [port-labs_blueprint.region, module.port_sqs]
}

module "port_ec2_instance" {
  source     = "../ec2_instance"
  count      = contains(var.resources, "ec2_instance") ? 1 : 0
  depends_on = [port-labs_blueprint.region]
}

module "port_load_balancer" {
  source     = "../load_balancer"
  count      = contains(var.resources, "load_balancer") ? 1 : 0
  depends_on = [port-labs_blueprint.region]
}
