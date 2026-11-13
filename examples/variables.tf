variable "globacct" {
  description = "Subdomain of the SAP BTP global account."
  type        = string
}

variable "subaccount_name" {
  description = "Name of the SAP BTP subaccount."
  type        = string
}

variable "subdomain" {
  description = "Subdomain of the SAP BTP subaccount."
  type        = string
}

variable "admins" {
  description = "Users given the SAP HANA Cloud Administrator role collection."
  type        = list(string)
}

variable "region" {
  description = "Region of the SAP BTP subaccount."
  type        = string
  default     = "eu10"
}
