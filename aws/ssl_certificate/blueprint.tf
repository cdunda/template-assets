terraform {
  required_providers {
    port-labs = {
      source  = "port-labs/port-labs"
      version = "0.10.4"
    }
  }
}

resource "port-labs_blueprint" "ssl_certificate" {
  title      = "SSL Certificate"
  icon       = "Cloud"
  identifier = "ssl_certificate"

  properties {
    identifier = "domainName"
    type       = "string"
    title      = "Domain Name"
  }

  properties {
    identifier = "subjectAlternativeNames"
    type       = "array"
    title      = "Subject Alternative Names"
  }

  properties {
    identifier = "status"
    type       = "string"
    title      = "Status"
  }

  properties {
    identifier = "type"
    type       = "string"
    title      = "Certificate Type"
  }

  properties {
    identifier = "tags"
    type       = "array"
    title      = "Tags"
  }

  properties {
    identifier = "arn"
    type       = "string"
    title      = "ARN"
  }

  relations {
    identifier = "hosted_zones"
    many       = true
    required   = false
    target     = "hosted_zone"
    title      = "Hosted Zones"
  }

  relations {
    identifier = "region"
    many       = false
    required   = false
    target     = "region"
    title      = "Region"
  }
}
