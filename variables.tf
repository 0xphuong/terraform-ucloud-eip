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
      count       = number
      bandwidth   = optional(number)
      charge_mode = optional(string)
      remark      = optional(string)

      # Whether to bind the EIP. Leave unset and it is inferred from
      # resource_id, which only works when that id is known at plan time. When
      # resource_id comes from a resource being created in the same apply the
      # inference cannot be evaluated, and Terraform fails with "Invalid
      # for_each argument" — set associate = true explicitly in that case.
      associate     = optional(bool)
      resource_id   = optional(string)
      resource_type = optional(string, "instance")

      overrides = optional(map(object({
        bandwidth     = optional(number)
        associate     = optional(bool)
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
  validation {
    condition     = var.eips.charge_mode == "share_bandwidth" ? var.eips.share_bandwidth_package_id != null : true
    error_message = "share_bandwidth_package_id is required when charge_mode is 'share_bandwidth'."
  }
  validation {
    condition = alltrue([
      for k, v in var.eips.eip_configs :
      v.charge_mode == null ? true : contains(["traffic", "bandwidth", "share_bandwidth"], v.charge_mode)
    ])
    error_message = "Per-group charge_mode must be 'traffic', 'bandwidth', or 'share_bandwidth'."
  }
  validation {
    condition     = var.eips.charge_type == "dynamic" ? true : var.eips.duration >= 1
    error_message = "duration must be >= 1 when charge_type is 'month' or 'year'."
  }
}
