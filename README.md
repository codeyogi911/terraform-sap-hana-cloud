# Terraform Module for SAP HANA Cloud on SAP BTP

This Terraform module provisions and manages SAP HANA Cloud resources on the SAP Business Technology Platform (BTP). It simplifies the process of setting up SAP HANA Cloud databases, assigning role collections, and managing entitlements within a subaccount.

## Requirements

- Terraform 1.12 or later
- SAP/btp provider `>= 1.22.0, < 2.0.0` (tested with 1.26.0). Pin the exact version in your root module.
- An SAP BTP subaccount you administer, with SAP HANA Cloud entitlements in the global account

Coming from 1.x? Read [CHANGELOG.md](CHANGELOG.md): the upgrade keeps your database.

## Usage

```hcl
module "hana_cloud" {
  source  = "codeyogi911/hana-cloud/sap"
  version = "~> 2.0"

  subaccount_id   = btp_subaccount.this.id
  instance_name   = "my-hana-instance"
  memory          = 32
  vcpu            = 2
  admins          = ["admin@example.com"]
  viewers         = ["viewer@example.com"]
  security_admins = ["sec-admin@example.com"]
  whitelist_ips   = ["203.0.113.0/24"]

  timeouts = { create = "60m", update = "60m", delete = "30m" }
}
```

### Mapped to a Cloud Foundry space

```hcl
module "hana_cloud" {
  source  = "codeyogi911/hana-cloud/sap"
  version = "~> 2.0"

  subaccount_id = btp_subaccount.this.id
  instance_name = "my-hana-instance"
  database_mappings = [
    {
      organization_guid = data.cloudfoundry_org.org.id
      space_guid        = cloudfoundry_space.space.id
    }
  ]
}
```

### More database settings

```hcl
module "hana_cloud" {
  source  = "codeyogi911/hana-cloud/sap"
  version = "~> 2.0"

  subaccount_id    = btp_subaccount.this.id
  instance_name    = "my-hana-instance"
  storage          = 120
  enabled_services = { scriptserver = true, docstore = true }
  product_version  = { releaseCycle = "generally-available-quarterly", track = "2025.2" }

  # Anything SAP HANA Cloud accepts that the module does not type yet
  additional_parameters = { slaLevel = "standard" }
}
```

The module always asks SAP to generate the DBADMIN password (`generateSystemPassword`), so no password is written to Terraform state. Read it from a service binding or reset it in SAP HANA Cloud Central.

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `subaccount_id` | ID of the SAP BTP subaccount (required) | `string` | n/a |
| `instance_name` | Name of the SAP HANA Cloud instance (required) | `string` | n/a |
| `create_instance` | Create the database; false manages only entitlements, tools and roles | `bool` | `true` |
| `service_name` | Service offering | `string` | `"hana-cloud"` |
| `plan_name` | Service plan | `string` | `"hana-td"` |
| `hana_cloud_tools_app_name` | SAP HANA Cloud Central app | `string` | `"hana-cloud-tools"` |
| `hana_cloud_tools_plan_name` | SAP HANA Cloud Central plan | `string` | `"tools"` |
| `admins` | Users given SAP HANA Cloud Administrator | `list(string)` | `[]` |
| `viewers` | Users given SAP HANA Cloud Viewer | `list(string)` | `[]` |
| `security_admins` | Users given SAP HANA Cloud Security Administrator | `list(string)` | `[]` |
| `user_origin` | Origin key of a custom identity provider for those users | `string` | `null` |
| `memory` | Memory in GB (at least 15) | `number` | `32` |
| `vcpu` | vCPUs | `number` | `2` |
| `storage` | Disk storage in GB | `number` | `null` |
| `whitelist_ips` | Allowed IPv4 addresses or CIDR ranges; `[]` allows none from outside BTP | `list(string)` | `[]` |
| `database_mappings` | Cloud Foundry orgs and spaces the database is mapped to | `list(object)` | `[]` |
| `enabled_services` | `scriptserver`, `docstore`, `dpserver` switches | `map(bool)` | `null` |
| `service_stopped` | Stop (`true`) or start (`false`) the database | `bool` | `null` |
| `product_version` | SAP HANA Cloud `productVersion` object | `map(string)` | `null` |
| `additional_parameters` | Further instance parameters; typed inputs win | `any` | `{}` |
| `labels` | Instance labels | `map(set(string))` | `{}` |
| `timeouts` | `create`, `update`, `delete` durations | `object` | `null` (provider: 10 minutes) |

## Outputs

| Name | Description |
|------|-------------|
| `instance_id` | ID of the service instance |
| `instance_name` | Name of the service instance |
| `dashboard_url` | The instance in SAP HANA Cloud Central |
| `tools_url` | SAP HANA Cloud Central for the subaccount |

## Safety

The database carries `lifecycle { prevent_destroy = true }`. A plan that would replace or destroy it fails. To delete a database on purpose, take the module call out and add this to the calling module:

```hcl
removed {
  from = module.hana_cloud.btp_subaccount_service_instance.my_sap_hana_cloud_instance
  lifecycle {
    destroy = true
  }
}
```

## Testing

`terraform test` runs the suite in `tests/` against a mocked provider, so it needs no SAP BTP account. `tests/upgrade.tftest.hcl` builds state with module 1.5.0 and checks that 2.x keeps the same database.

## Contributing

Contributions to this module are welcome. Please ensure that your pull requests are well-documented and include test cases where applicable.

## License

Apache 2 Licensed. See [LICENSE](https://github.com/codeyogi911/terraform-sap-hana-cloud/blob/main/LICENSE) for full details.
