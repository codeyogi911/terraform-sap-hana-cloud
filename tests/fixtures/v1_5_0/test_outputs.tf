# Added for the upgrade test only; 1.5.0 had no outputs.
output "instance_id" {
  value = one(concat(
    btp_subaccount_service_instance.my_sap_hana_cloud_instance[*].id,
    btp_subaccount_service_instance.my_sap_hana_cloud_instance_with_mappings[*].id,
  ))
}
