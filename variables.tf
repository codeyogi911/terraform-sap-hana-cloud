variable "subaccount_id" {
  description = "ID of the SAP BTP subaccount."
  type        = string
  nullable    = false
}

variable "instance_name" {
  description = "Name of the SAP HANA Cloud instance."
  type        = string
  nullable    = false
}

variable "create_instance" {
  description = "Create the database instance. Set false to manage only the entitlements, SAP HANA Cloud Central and role collections."
  type        = bool
  default     = true
  nullable    = false
}

variable "service_name" {
  description = "Service offering of SAP HANA Cloud."
  type        = string
  default     = "hana-cloud"
  nullable    = false
}

variable "plan_name" {
  description = "Service plan of SAP HANA Cloud, for example hana, hana-td or hana-free."
  type        = string
  default     = "hana-td"
  nullable    = false
}

variable "hana_cloud_tools_app_name" {
  description = "App name of SAP HANA Cloud Central (tools)."
  type        = string
  default     = "hana-cloud-tools"
  nullable    = false
}

variable "hana_cloud_tools_plan_name" {
  description = "Plan of SAP HANA Cloud Central (tools)."
  type        = string
  default     = "tools"
  nullable    = false
}

variable "admins" {
  description = "Users given the SAP HANA Cloud Administrator role collection."
  type        = list(string)
  default     = []
}

variable "viewers" {
  description = "Users given the SAP HANA Cloud Viewer role collection."
  type        = list(string)
  default     = []
}

variable "security_admins" {
  description = "Users given the SAP HANA Cloud Security Administrator role collection."
  type        = list(string)
  default     = []
}

variable "user_origin" {
  description = "Origin key of the identity provider the users above sign in with. null keeps the provider default, as module 1.x did. Changing it replaces the assignments."
  type        = string
  default     = null
}

variable "memory" {
  description = "Memory of the database in GB."
  type        = number
  default     = 32
  nullable    = false

  validation {
    condition     = var.memory >= 15
    error_message = "SAP HANA Cloud needs at least 15 GB of memory."
  }
}

variable "vcpu" {
  description = "Number of vCPUs of the database."
  type        = number
  default     = 2
  nullable    = false

  validation {
    condition     = var.vcpu >= 1 && floor(var.vcpu) == var.vcpu
    error_message = "vcpu must be a whole number of at least 1."
  }
}

variable "storage" {
  description = "Disk storage in GB. null leaves the SAP default for the chosen memory."
  type        = number
  default     = null
}

variable "whitelist_ips" {
  description = "IP addresses or CIDR ranges allowed to connect. An empty list allows no connections from outside SAP BTP; [\"0.0.0.0/0\"] allows all."
  type        = list(string)
  default     = []
  nullable    = false

  validation {
    condition     = alltrue([for ip in var.whitelist_ips : can(cidrhost(strcontains(ip, "/") ? ip : "${ip}/32", 0))])
    error_message = "Each entry must be an IPv4 address or CIDR range, for example 203.0.113.10 or 203.0.113.0/24."
  }
}

variable "database_mappings" {
  description = "Cloud Foundry orgs and spaces (or Kyma namespaces) the database is mapped to, so HDI containers can be created there."
  type = list(object({
    organization_guid = string
    space_guid        = string
  }))
  default  = []
  nullable = false
}

variable "enabled_services" {
  description = "Optional database services to switch on, for example { scriptserver = true, docstore = true, dpserver = false }. null leaves them unchanged."
  type        = map(bool)
  default     = null
}

variable "service_stopped" {
  description = "true stops the database, false starts it, null leaves it as it is. Data is kept while stopped."
  type        = bool
  default     = null
}

variable "product_version" {
  description = "Release to run, as SAP HANA Cloud's productVersion object, for example { releaseCycle = \"generally-available-quarterly\", track = \"2025.2\" }. null leaves the version to SAP's maintenance."
  type        = map(string)
  default     = null
}

variable "additional_parameters" {
  description = "Further instance parameters merged into the data object, for parameters this module does not type yet. The typed inputs win on a clash. Never put systempassword here: the module asks SAP to generate it."
  type        = any
  default     = {}
  nullable    = false

  validation {
    condition     = !contains(keys(var.additional_parameters), "systempassword")
    error_message = "Do not pass systempassword: the module sets generateSystemPassword, so no password reaches Terraform state."
  }
}

variable "labels" {
  description = "Labels on the service instance, as a map of label name to a set of values."
  type        = map(set(string))
  default     = {}
  nullable    = false
}

variable "timeouts" {
  description = "Client-side timeouts for the database instance, for example { create = \"60m\", update = \"60m\", delete = \"30m\" }. The provider waits 10 minutes by default, which a new database often exceeds. Setting this on an existing instance plans one in-place update."
  type = object({
    create = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
}
