terraform {
  # 1.12 is the oldest core that stores resource identity in state. SAP/btp
  # declares identity schemas, and on older core a resource deleted outside
  # Terraform fails every later plan with "Missing Resource Identity After Read".
  required_version = ">= 1.12"

  required_providers {
    btp = {
      source = "SAP/btp"
      # 1.22.0 added service instances by offering and plan name. The module
      # sets a range, never an exact version, so the root module picks the
      # provider release; pin the exact version in your root module.
      version = ">= 1.22.0, < 2.0.0"
    }
  }
}
