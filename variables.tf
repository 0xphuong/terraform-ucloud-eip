variable "eips" {
  description = "Shared EIP parameters and per-group configurations"
  type = object({
    internet_type              = string
    charge_mode                = optional(string, "bandwidth")
    charge_type                = optional(string, "month")
    duration                   = optional(number, 1)
    bandwidth                  = optional(number, 1)
    tag                        = optional(string, "Default")
    share_bandwidth_package_id = optional(string)

    eip_configs = map(object({
      count         = number
      bandwidth     = optional(number)
      charge_mode   = optional(string)
      remark        = optional(string)
      resource_id   = optional(string)
      resource_type = optional(string, "instance")

      overrides = optional(map(object({
        bandwidth     = optional(number)
        resource_id   = optional(string)
        resource_type = optional(string)
        remark        = optional(string)
      })), {})
    }))
  })

  validation {
    condition     = alltrue([for k, v in var.eips.eip_configs : v.count >= 1])
    error_message = "Each eip_config must have count >= 1."
  }
  validation {
    condition     = contains(["bgp", "international"], var.eips.internet_type)
    error_message = "internet_type must be 'bgp' or 'international'."
  }
  validation {
    condition     = contains(["traffic", "bandwidth", "share_bandwidth"], var.eips.charge_mode)
    error_message = "charge_mode must be 'traffic', 'bandwidth', or 'share_bandwidth'."
  }
  validation {
    condition     = contains(["month", "year", "dynamic"], var.eips.charge_type)
    error_message = "charge_type must be 'month', 'year', or 'dynamic'."
  }
}
