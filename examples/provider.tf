terraform {
  required_providers {
    btp = {
      source  = "SAP/btp"
      version = "~>1.5.0"
    }
  }
}

provider "btp" {
  globalaccount = var.globacct
  username      = var.username
  password      = var.password
}