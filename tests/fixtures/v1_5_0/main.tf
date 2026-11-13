data "btp_globalaccount" "this" {}

locals {
  params_without_mappings = {
    memory                 = var.memory
    vcpu                   = var.vcpu
    generateSystemPassword = true
    whitelistIPs           = var.whitelist_ips
  }
  params_with_mappings = {
    databaseMappings       = var.database_mappings
    memory                 = var.memory
    vcpu                   = var.vcpu
    generateSystemPassword = true
    whitelistIPs           = var.whitelist_ips
  }
}

resource "btp_subaccount_entitlement" "hana_cloud" {
  subaccount_id = var.subaccount_id
  service_name  = var.service_name
  plan_name     = var.plan_name
}

resource "btp_subaccount_entitlement" "tools" {
  subaccount_id = var.subaccount_id
  service_name  = var.hana_cloud_tools_app_name
  plan_name     = var.hana_cloud_tools_plan_name
}

resource "btp_subaccount_role_collection_assignment" "hana_admin" {
  subaccount_id        = var.subaccount_id
  for_each             = var.admins == null ? {} : { for user in var.admins : user => user }
  role_collection_name = "SAP HANA Cloud Administrator"
  user_name            = each.value
  depends_on = [
    btp_subaccount_subscription.hana_cloud_tools,
  ]
}

resource "btp_subaccount_role_collection_assignment" "hana_viewer" {
  subaccount_id        = var.subaccount_id
  for_each             = var.viewers == null ? {} : { for user in var.viewers : user => user }
  role_collection_name = "SAP HANA Cloud Viewer"
  user_name            = each.value
  depends_on = [
    btp_subaccount_subscription.hana_cloud_tools,
  ]
}

resource "btp_subaccount_role_collection_assignment" "hana_security_admin" {
  subaccount_id        = var.subaccount_id
  for_each             = var.security_admins == null ? {} : { for user in var.security_admins : user => user }
  role_collection_name = "SAP HANA Cloud Security Administrator"
  user_name            = each.value
  depends_on = [
    btp_subaccount_subscription.hana_cloud_tools,
  ]
}

resource "btp_subaccount_subscription" "hana_cloud_tools" {
  subaccount_id = var.subaccount_id
  app_name      = var.hana_cloud_tools_app_name
  plan_name     = var.hana_cloud_tools_plan_name
  depends_on    = [btp_subaccount_entitlement.tools]
}

data "btp_subaccount_service_plan" "my_hana_plan" {
  subaccount_id = var.subaccount_id
  name          = var.plan_name
  offering_name = var.service_name
  depends_on = [
    btp_subaccount_entitlement.hana_cloud
  ]
}

#Create or Update an SAP HANA Cloud database instance
resource "btp_subaccount_service_instance" "my_sap_hana_cloud_instance" {
  count          = var.database_mappings == null ? 1 : 0
  subaccount_id  = var.subaccount_id
  serviceplan_id = data.btp_subaccount_service_plan.my_hana_plan.id
  name           = var.instance_name
  parameters = jsonencode({
    data = local.params_without_mappings
  })
  depends_on = [
    btp_subaccount_subscription.hana_cloud_tools
  ]
}

resource "btp_subaccount_service_instance" "my_sap_hana_cloud_instance_with_mappings" {
  count          = var.database_mappings == null ? 0 : 1
  subaccount_id  = var.subaccount_id
  serviceplan_id = data.btp_subaccount_service_plan.my_hana_plan.id
  name           = var.instance_name
  parameters = jsonencode({
    data = local.params_with_mappings
  })
  depends_on = [
    btp_subaccount_subscription.hana_cloud_tools
  ]
}
