variable "service_name" {
  description = "The name of the SAP HANA Cloud service"
  type        = string
  default     = "hana-cloud"
}

variable "plan_name" {
  description = "The name of the SAP HANA Cloud plan"
  type        = string
  default     = "hana-td"
}

variable "instance_name" {
  description = "The name of the SAP HANA Cloud instance"
  type        = string
}

variable "hana_cloud_tools_app_name" {
  description = "The name of the SAP HANA Cloud Tools application"
  type        = string
  default     = "hana-cloud-tools"
}

variable "hana_cloud_tools_plan_name" {
  description = "The name of the SAP HANA Cloud Tools plan"
  type        = string
  default     = "tools"
}

variable "subaccount_id" {
  description = "The ID of the subaccount"
  type        = string
}

variable "admins" {
  description = "List of users to assign the SAP HANA Cloud Administrator role"
  type        = list(string)
  default     = null
}

variable "viewers" {
  description = "List of users to assign the SAP HANA Cloud Viewer role"
  type        = list(string)
  default     = null
}

variable "security_admins" {
  description = "List of users to assign the SAP HANA Cloud Security Administrator role"
  type        = list(string)
  default     = null
}

variable "memory" {
  description = "The memory size of the SAP HANA Cloud instance"
  type        = number
  default     = 32
}

variable "vcpu" {
  description = "The number of vCPUs of the SAP HANA Cloud instance"
  type        = number
  default     = 2
}

variable "database_mappings" {
  description = "The database mapping for the SAP HANA Cloud instance"
  type = list(object({
    organization_guid = string
    space_guid        = string
  }))
  default = null
}

variable "labels" {
  description = "The labels of the SAP HANA Cloud instance"
  type        = map(string)
  default     = {}
}

variable "whitelist_ips" {
  description = "The list of IP addresses to whitelist"
  type        = list(string)
  default     = []
}
