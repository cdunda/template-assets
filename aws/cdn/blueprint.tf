terraform {
  required_providers {
    port-labs = {
      source  = "port-labs/port-labs"
      version = "0.10.4"
    }
  }
}

resource "port-labs_blueprint" "cdn" {
  title      = "CDN"
  icon       = "Cloud"
  identifier = "cdn"

  properties {
    identifier = "domainName"
    type       = "string"
    title      = "Domain Name"
  }

  properties {
    identifier = "aliases"
    type       = "array"
    title      = "Aliases"
  }

  properties {
    identifier = "comment"
    type       = "string"
    title      = "Comment"
  }

  properties {
    identifier = "enabled"
    type       = "boolean"
    title      = "Enabled"
  }

  properties {
    identifier = "originConfig"
    type       = "array"
    title      = "Origin Configuration"
  }

  properties {
    identifier = "defaultCacheBehavior"
    type       = "object"
    title      = "Default Cache Behavior"
  }

  properties {
    identifier = "cacheBehaviors"
    type       = "array"
    title      = "Cache Behaviors"
  }

  properties {
    identifier = "loggingConfig"
    type       = "object"
    title      = "Logging Configuration"
  }

  properties {
    identifier = "viewerProtocolPolicy"
    type       = "string"
    title      = "Viewer Protocol Policy"
  }

  relations {
    identifier = "object_storages"
    many       = true
    required   = false
    target     = "object_storage"
    title      = "Object Storages"
  }

  relations {
    identifier = "ssl_certificate"
    many       = false
    required   = false
    target     = "ssl_certificate"
    title      = "SSL Certificate"
  }
}
