terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "3.10.0"
    }
  }
}

locals {
  recordit = flatten([
    for domain, d_tiedot in var.domainit : [
      for record in d_tiedot.recordit : [
        for target in setunion(
          linode_instance.instance1.ipv4, 
          toset([linode_instance.instance1.ipv6])
        ) : {
          domain = domain
          domain_id = linode_domain.domain[domain].id
          name = record.name
          record_type = record.record_type
          target = target
        }
      ]
    ]
  ])
}

variable "domainit" {
  type = map(object({
    type = optional(string, "master")
    soa_email = optional(string, "lauri.mauranen@gmail.com")
    recordit = optional(list(object({ 
      name = string
      record_type = string
    })), [])
  }))

  default = {}
}

resource "linode_domain" "domain" {
  for_each = var.domainit

  domain = each.key
  type = each.value.type
  soa_email = each.value.soa_email
}

resource "linode_domain_record" "record" {
    for_each = {
      for r in local.recordit : "${r.domain}.${r.name}.${r.target}" => r
    }

    domain_id = each.value.domain_id
    name = each.value.name
    record_type = each.value.record_type
    target = each.value.target
}
