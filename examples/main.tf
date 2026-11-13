resource "btp_subaccount" "this" {
  name      = var.subaccount_name
  subdomain = var.subdomain
  region    = var.region
}

module "hana_cloud" {
  source = "../"

  subaccount_id = btp_subaccount.this.id
  instance_name = "hana-cloud"
  admins        = var.admins
  whitelist_ips = ["203.0.113.0/24"]

  enabled_services = { scriptserver = true }
  timeouts         = { create = "60m", update = "60m", delete = "30m" }
}

output "hana_cloud_central" {
  value = module.hana_cloud.dashboard_url
}
