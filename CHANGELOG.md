# Changelog

## 2.0.0

Upgrading from 1.x keeps your database: the instance moves to its new address
and the parameters SAP receives stay the same. Run `terraform plan` first. It
should show only the move (and, if you had no outputs before, new outputs). If
it shows the instance being replaced, stop: `prevent_destroy` will refuse the
plan anyway.

### Breaking

- Terraform 1.12 or later. Older core never stores resource identity, so a
  resource deleted outside Terraform breaks every later plan.
- SAP/btp `>= 1.22.0, < 2.0.0` instead of exactly 1.21.3. The module no longer
  decides your provider version; pin it in your root module (1.26.0 tested).
- One database resource instead of two. A `moved` block carries a 1.x instance
  made with `database_mappings` to
  `btp_subaccount_service_instance.my_sap_hana_cloud_instance[0]`; one made
  without mappings is already there.
- The database has `prevent_destroy`. Delete it on purpose with a `removed`
  block, never by accident through a changed input.
- `database_mappings` defaults to `[]`, and an empty list now means no mappings
  (1.x sent an empty `databaseMappings` list).
- `labels` is now `map(set(string))` and is applied to the instance (it was
  accepted but ignored in 1.x).
- `admins`, `viewers` and `security_admins` default to `[]`; `null` still works.

### Added

- The instance is found by offering and plan name (SAP/btp 1.22), so the plan
  data source and its extra API call are gone.
- `storage`, `enabled_services` (script server, document store, data
  provisioning server), `service_stopped`, `product_version` and
  `additional_parameters` for any other SAP HANA Cloud parameter. A
  `systempassword` is refused: SAP generates it, so it never reaches state.
- `create_instance = false` to manage only entitlements, SAP HANA Cloud
  Central and role collections.
- `user_origin` for users from a custom identity provider.
- `timeouts`. The provider gives up after 10 minutes by default, and a new
  database often takes longer.
- Outputs: `instance_id`, `instance_name`, `dashboard_url`, `tools_url`.
- Input checks for memory, vCPUs and IP ranges.
- `terraform test` suite with a mocked provider, including an upgrade test from
  1.5.0 state, and CI on Terraform 1.12 and the latest release.

### Removed

- The unused `btp_globalaccount` data source.
- Committed `.terraform.lock.hcl` files; the root module owns the lock.

## 1.5.0

- SAP/btp 1.21.3.
