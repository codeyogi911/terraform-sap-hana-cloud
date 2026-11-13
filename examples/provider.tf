terraform {
  required_version = ">= 1.12"

  required_providers {
    btp = {
      source  = "SAP/btp"
      version = "~> 1.26.0"
    }
  }
}

# Sign-in comes from the environment, never from variables: BTP_USERNAME and
# BTP_PASSWORD, or better a short-lived token from your CI's OIDC sign-in in
# BTP_ASSERTION together with BTP_IDP. See the provider's authentication docs.
provider "btp" {
  globalaccount = var.globacct
}
