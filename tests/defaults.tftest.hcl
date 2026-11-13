mock_provider "btp" {}

variables {
  subaccount_id = "00000000-0000-0000-0000-000000000001"
  instance_name = "hana-test"
}

run "unmapped_instance_keeps_1x_parameters" {
  command = plan

  assert {
    condition = jsondecode(btp_subaccount_service_instance.my_sap_hana_cloud_instance[0].parameters) == {
      data = {
        memory                 = 32
        vcpu                   = 2
        generateSystemPassword = true
        whitelistIPs           = []
      }
    }
    error_message = "Parameters must match what module 1.x sent, or upgrading would update the instance."
  }

  assert {
    condition     = btp_subaccount_service_instance.my_sap_hana_cloud_instance[0].serviceplan_name == "hana-td" && btp_subaccount_service_instance.my_sap_hana_cloud_instance[0].service_offering_name == "hana-cloud"
    error_message = "The instance must be found by offering and plan name."
  }
}

run "mapped_instance_keeps_1x_parameters" {
  command = plan

  variables {
    whitelist_ips     = ["0.0.0.0/0"]
    database_mappings = [{ organization_guid = "org-1", space_guid = "space-1" }]
  }

  assert {
    condition = jsondecode(btp_subaccount_service_instance.my_sap_hana_cloud_instance[0].parameters) == {
      data = {
        databaseMappings       = [{ organization_guid = "org-1", space_guid = "space-1" }]
        memory                 = 32
        vcpu                   = 2
        generateSystemPassword = true
        whitelistIPs           = ["0.0.0.0/0"]
      }
    }
    error_message = "Mapped parameters must match what module 1.x sent."
  }
}

run "new_parameters_are_sent_when_set" {
  command = plan

  variables {
    storage               = 120
    enabled_services      = { scriptserver = true, docstore = false }
    service_stopped       = false
    product_version       = { releaseCycle = "generally-available-quarterly", track = "2025.2" }
    additional_parameters = { slaLevel = "standard", memory = 999 }
  }

  assert {
    condition = jsondecode(btp_subaccount_service_instance.my_sap_hana_cloud_instance[0].parameters).data == {
      memory                 = 32
      vcpu                   = 2
      storage                = 120
      generateSystemPassword = true
      whitelistIPs           = []
      enabledservices        = { scriptserver = true, docstore = false }
      serviceStopped         = false
      productVersion         = { releaseCycle = "generally-available-quarterly", track = "2025.2" }
      slaLevel               = "standard"
    }
    error_message = "Typed inputs and additional_parameters must reach the instance, typed inputs winning."
  }
}

run "roles_are_keyed_by_user" {
  command = plan

  variables {
    admins          = ["a@example.com", "b@example.com"]
    viewers         = null
    security_admins = ["a@example.com"]
  }

  assert {
    condition     = keys(btp_subaccount_role_collection_assignment.hana_admin) == ["a@example.com", "b@example.com"]
    error_message = "Admin assignments must keep the 1.x keys (the user name)."
  }

  assert {
    condition     = length(btp_subaccount_role_collection_assignment.hana_viewer) == 0
    error_message = "null viewers must still work as in 1.x."
  }
}

run "no_instance" {
  command = plan

  variables {
    create_instance = false
  }

  assert {
    condition     = length(btp_subaccount_service_instance.my_sap_hana_cloud_instance) == 0 && output.instance_id == null
    error_message = "create_instance = false must not plan a database."
  }
}

run "rejects_system_password" {
  command = plan

  variables {
    additional_parameters = { systempassword = "not-allowed" }
  }

  expect_failures = [var.additional_parameters]
}

run "rejects_bad_ip" {
  command = plan

  variables {
    whitelist_ips = ["not-an-ip"]
  }

  expect_failures = [var.whitelist_ips]
}
