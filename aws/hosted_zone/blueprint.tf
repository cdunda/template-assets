terraform {
  required_providers {
    port-labs = {
      source  = "port-labs/port-labs"
      version = "0.10.4"
    }
  }
}

resource "port-labs_blueprint" "hosted_zone" {
  title      = "Hosted Zone"
  icon       = "Cloud"
  identifier = "hosted_zone"

  properties {
    identifier = "name"
    type       = "string"
    title      = "Domain Name"
  }

  properties {
    identifier = "nameServers"
    type       = "array"
    title      = "Name Servers"
  }

  properties {
    identifier = "zoneType"
    type       = "string"
    title      = "Zone Type"
    enum       = ["Public", "Private"]
  }

  properties {
    identifier = "vpcId"
    type       = "string"
    title      = "VPC ID"
  }

  properties {
    identifier = "recordSets"
    type       = "array"
    title      = "Record Sets"
  }

  properties {
    identifier = "comment"
    type       = "string"
    title      = "Comment"
  }

  properties {
    identifier = "saas_provider"
    type       = "string"
    title      = "SaaS Provider"
  }
}
