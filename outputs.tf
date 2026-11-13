output "instance_id" {
  description = "ID of the SAP HANA Cloud service instance, or null when create_instance is false."
  value       = one(btp_subaccount_service_instance.my_sap_hana_cloud_instance[*].id)
}

output "instance_name" {
  description = "Name of the SAP HANA Cloud service instance, or null when create_instance is false."
  value       = one(btp_subaccount_service_instance.my_sap_hana_cloud_instance[*].name)
}

output "dashboard_url" {
  description = "Link to the instance in SAP HANA Cloud Central, or null when create_instance is false."
  value       = one(btp_subaccount_service_instance.my_sap_hana_cloud_instance[*].dashboard_url)
}

output "tools_url" {
  description = "Link to SAP HANA Cloud Central for the subaccount."
  value       = btp_subaccount_subscription.hana_cloud_tools.subscription_url
}
