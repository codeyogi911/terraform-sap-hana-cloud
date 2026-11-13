# Builds state with module 1.5.0, then plans module 2.x against that state and
# checks the database instance keeps its ID, so upgrading moves it instead of
# creating a new, empty database.
mock_provider "btp" {}

variables {
  subaccount_id = "00000000-0000-0000-0000-000000000001"
  instance_name = "hana-test"
  admins        = ["a@example.com"]
}

run "v1_with_mappings" {
  state_key = "mapped"
  module {
    source = "./tests/fixtures/v1_5_0"
  }
  variables {
    database_mappings = [{ organization_guid = "org-1", space_guid = "space-1" }]
    whitelist_ips     = ["0.0.0.0/0"]
  }
}

run "v2_with_mappings_moves_instance" {
  state_key = "mapped"
  command   = plan
  variables {
    database_mappings = [{ organization_guid = "org-1", space_guid = "space-1" }]
    whitelist_ips     = ["0.0.0.0/0"]
  }

  assert {
    condition     = btp_subaccount_service_instance.my_sap_hana_cloud_instance[0].id == run.v1_with_mappings.instance_id
    error_message = "The mapped 1.x instance must move to the new address, not be created again."
  }
}

run "v1_without_mappings" {
  state_key = "unmapped"
  module {
    source = "./tests/fixtures/v1_5_0"
  }
}

run "v2_without_mappings_keeps_instance" {
  state_key = "unmapped"
  command   = plan

  assert {
    condition     = btp_subaccount_service_instance.my_sap_hana_cloud_instance[0].id == run.v1_without_mappings.instance_id
    error_message = "The unmapped 1.x instance must stay where it is."
  }
}
