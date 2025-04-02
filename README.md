# Terraform Module for SAP HANA Cloud on SAP BTP

This Terraform module provisions and manages SAP HANA Cloud resources on the SAP Business Technology Platform (BTP). It simplifies the process of setting up SAP HANA Cloud databases, assigning role collections, and managing entitlements within a subaccount.

## Requirements

- Terraform >= 1.8
- SAP BTP Provider for Terraform ~> 1.11.0
- An SAP BTP account with sufficient permissions to manage resources
- SAP HANA Cloud entitlements in your global account

## Usage

To use this module in your Terraform configuration:

```hcl
module "hana_cloud" {
  source        = "codeyogi911/hana-cloud/sap"
  version       = "1.1.2"
  
  subaccount_id             = "your-subaccount-id"
  instance_name             = "my-hana-instance"
  memory                    = 32
  vcpu                      = 4
  admins                    = ["admin@example.com"]
  viewers                   = ["viewer@example.com"]
  security_admins           = ["sec-admin@example.com"]
  whitelist_ips             = ["192.168.0.1"]
}
```

### With Database Mappings (for CF or Kyma environments)

```hcl
module "hana_cloud" {
  source        = "codeyogi911/hana-cloud/sap"
  version       = "1.1.4"
  
  subaccount_id             = "your-subaccount-id"
  instance_name             = "my-hana-instance"
  database_mappings         = [
    {
      organization_guid = "your-cf-org-id"
      space_guid        = "your-space-guid"
    }
  ]
}
```

### Complete Example with Subaccount Creation

```hcl
resource "btp_subaccount" "this" {
  name      = "my-subaccount"
  subdomain = "my-subdomain"
  region    = "eu10"
}

module "hana_cloud" {
  source        = "codeyogi911/hana-cloud/sap"
  version       = "1.1.2"
  
  instance_name = "hana-cloud"
  subaccount_id = btp_subaccount.this.id
  admins        = ["admin@example.com"]
  whitelist_ips = ["0.0.0.0/0"]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `subaccount_id` | The ID of the SAP BTP subaccount | `string` | n/a | yes |
| `instance_name` | Name of the SAP HANA Cloud instance | `string` | n/a | yes |
| `service_name` | The name of the SAP HANA Cloud service | `string` | `"hana-cloud"` | no |
| `plan_name` | The name of the SAP HANA Cloud plan | `string` | `"hana-td"` | no |
| `hana_cloud_tools_app_name` | The name of the SAP HANA Cloud Tools application | `string` | `"hana-cloud-tools"` | no |
| `hana_cloud_tools_plan_name` | The name of the SAP HANA Cloud Tools plan | `string` | `"tools"` | no |
| `admins` | List of users to assign the SAP HANA Cloud Administrator role | `list(string)` | `null` | no |
| `viewers` | List of users to assign the SAP HANA Cloud Viewer role | `list(string)` | `null` | no |
| `security_admins` | List of users to assign the SAP HANA Cloud Security Administrator role | `list(string)` | `null` | no |
| `memory` | The memory size of the SAP HANA Cloud instance in GB | `number` | `32` | no |
| `vcpu` | The number of vCPUs of the SAP HANA Cloud instance | `number` | `2` | no |
| `whitelist_ips` | The list of IP addresses to whitelist | `list(string)` | `[]` | no |
| `database_mappings` | Database mappings for CF or Kyma environments | `list(object)` | `null` | no |
| `labels` | The labels of the SAP HANA Cloud instance | `map(string)` | `{}` | no |

## Outputs

This module does not currently export any outputs.

## Features

- Provisions SAP HANA Cloud instances
- Sets up required entitlements
- Assigns role collections to users (Administrator, Viewer, Security Administrator)
- Configures resource allocation (memory, vCPU)
- Manages IP whitelisting for access control
- Supports database mappings for Cloud Foundry and Kyma environments

## Contributing

Contributions to this module are welcome. Please ensure that your pull requests are well-documented and include test cases where applicable.

## License

Apache 2 Licensed. See [LICENSE](https://github.com/codeyogi911/terraform-sap-hana-cloud/blob/main/LICENSE) for full details.
