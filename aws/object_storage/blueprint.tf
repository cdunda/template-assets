terraform {
  required_providers {
    port-labs = {
      source  = "port-labs/port-labs"
      version = "0.10.4"
    }
  }
}

resource "port-labs_blueprint" "object_storage" {
  title      = "Object Storage"
  icon       = "Bucket"
  identifier = "object_storage"

  properties {
    identifier = "saas_provider"
    type       = "string"
    title      = "SaaS Provider"
  }

  properties {
    identifier = "link"
    type       = "string"
    format     = "url"
    title      = "Link"
  }

  properties {
    identifier = "regionalDomainName"
    type       = "string"
    title      = "Regional Domain Name"
  }

  properties {
    identifier = "versioningStatus"
    type       = "string"
    title      = "Versioning Status"
    enum       = ["Enabled", "Suspended"]
  }

  properties {
    identifier = "encryption"
    type       = "array"
    title      = "Encryption"
  }

  properties {
    identifier = "lifecycleRules"
    type       = "array"
    title      = "Lifecycle Rules"
  }

  properties {
    identifier = "publicAccess"
    type       = "object"
    title      = "Public Access"
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
    identifier = "region"
    many       = false
    required   = false
    target     = "region"
    title      = "Region"
  }
}
