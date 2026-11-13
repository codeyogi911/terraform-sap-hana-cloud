locals {
  admins          = toset(coalesce(var.admins, []))
  viewers         = toset(coalesce(var.viewers, []))
  security_admins = toset(coalesce(var.security_admins, []))

  # Instance parameters sent to SAP HANA Cloud. Keys whose input is null are
  # left out, so the JSON for an instance made by module 1.x stays the same and
  # upgrading plans no change. The typed inputs win over additional_parameters.
  instance_data = merge(
    var.additional_parameters,
    { for key, value in {
      memory                 = var.memory
      vcpu                   = var.vcpu
      storage                = var.storage
      generateSystemPassword = true
      whitelistIPs           = var.whitelist_ips
      databaseMappings       = length(var.database_mappings) > 0 ? var.database_mappings : null
      enabledservices        = var.enabled_services
      serviceStopped         = var.service_stopped
      productVersion         = var.product_version
    } : key => value if value != null },
  )
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

resource "btp_subaccount_subscription" "hana_cloud_tools" {
  subaccount_id = var.subaccount_id
  app_name      = var.hana_cloud_tools_app_name
  plan_name     = var.hana_cloud_tools_plan_name
  depends_on    = [btp_subaccount_entitlement.tools]
}

resource "btp_subaccount_role_collection_assignment" "hana_admin" {
  for_each             = local.admins
  subaccount_id        = var.subaccount_id
  role_collection_name = "SAP HANA Cloud Administrator"
  user_name            = each.value
  origin               = var.user_origin
  depends_on           = [btp_subaccount_subscription.hana_cloud_tools]
}

resource "btp_subaccount_role_collection_assignment" "hana_viewer" {
  for_each             = local.viewers
  subaccount_id        = var.subaccount_id
  role_collection_name = "SAP HANA Cloud Viewer"
  user_name            = each.value
  origin               = var.user_origin
  depends_on           = [btp_subaccount_subscription.hana_cloud_tools]
}

resource "btp_subaccount_role_collection_assignment" "hana_security_admin" {
  for_each             = local.security_admins
  subaccount_id        = var.subaccount_id
  role_collection_name = "SAP HANA Cloud Security Administrator"
  user_name            = each.value
  origin               = var.user_origin
  depends_on           = [btp_subaccount_subscription.hana_cloud_tools]
}

# The SAP HANA Cloud database. Module 1.x had two copies of this resource, one
# with database mappings and one without; the moved block below carries the
# mapped one over, and the unmapped one already lives at this address.
resource "btp_subaccount_service_instance" "my_sap_hana_cloud_instance" {
  count = var.create_instance ? 1 : 0

  subaccount_id         = var.subaccount_id
  name                  = var.instance_name
  service_offering_name = var.service_name
  serviceplan_name      = var.plan_name
  parameters            = jsonencode({ data = local.instance_data })
  labels                = length(var.labels) > 0 ? var.labels : null
  timeouts              = var.timeouts

  depends_on = [
    btp_subaccount_entitlement.hana_cloud,
    btp_subaccount_subscription.hana_cloud_tools,
  ]

  lifecycle {
    # A replaced instance is a new, empty database. Any plan that would destroy
    # it fails instead; to really delete it, remove it with a removed block.
    prevent_destroy = true
  }
}

moved {
  from = btp_subaccount_service_instance.my_sap_hana_cloud_instance_with_mappings[0]
  to   = btp_subaccount_service_instance.my_sap_hana_cloud_instance[0]
}
