
# Define the input variables
variable "globacct" {
  description = "The name of the SAP BTP Global Account"
  type        = string
}

variable "username" {
  description = "The username of the SAP BTP Global Account Administrator"
  type        = string
}

variable "password" {
  description = "The password of the SAP BTP Global Account Administrator"
  type        = string
}

variable "subaccount_name" {
  description = "The name of the SAP BTP Subaccount"
  type        = string
}

variable "subdomain" {
  description = "The subdomain of the SAP BTP Subaccount"
  type        = string
}

variable "admins" {
  description = "The list of email addresses of the SAP BTP Subaccount Administrators"
  type        = list(string)

}

variable "region" {
  description = "The region of the SAP BTP Subaccount"
  type        = string
  default     = "eu10"
}
