locals {
  expanded_eips = flatten([
    for eip_name, config in var.eips.eip_configs : [
      for i in range(config.count) : {
        key  = "${eip_name}-${i}"
        name = "${eip_name}-${i}"

        bandwidth = try(
          config.overrides[tostring(i)].bandwidth != null ? config.overrides[tostring(i)].bandwidth : config.bandwidth,
          config.bandwidth
        )
        charge_mode = try(
          config.overrides[tostring(i)].charge_mode != null ? config.overrides[tostring(i)].charge_mode : config.charge_mode,
          config.charge_mode
        )
        remark = try(
          config.overrides[tostring(i)].remark != null ? config.overrides[tostring(i)].remark : config.remark,
          config.remark
        )
        resource_id = try(
          config.overrides[tostring(i)].resource_id != null ? config.overrides[tostring(i)].resource_id : config.resource_id,
          config.resource_id
        )
        resource_type = try(
          config.overrides[tostring(i)].resource_type != null ? config.overrides[tostring(i)].resource_type : config.resource_type,
          config.resource_type
        )
        associate = try(
          config.overrides[tostring(i)].associate != null ? config.overrides[tostring(i)].associate : config.associate,
          config.associate
        )
      }
    ]
  ])

  eip_map = { for e in local.expanded_eips : e.key => e }

  # for_each keys must be resolvable at plan time. Filtering on resource_id
  # breaks the moment that id belongs to a resource created in the same apply —
  # Terraform then reports "Invalid for_each argument". The explicit `associate`
  # flag keeps the key set static and leaves the unknown id in the value, which
  # is the arrangement Terraform asks for.
  associable_eips = {
    for k, e in local.eip_map : k => e
    if e.associate != null ? e.associate : e.resource_id != null
  }
}

resource "ucloud_eip" "this" {
  for_each = local.eip_map

  internet_type = var.eips.internet_type
  name          = each.value.name
  tag           = var.eips.tag
  charge_type   = var.eips.charge_type
  duration      = var.eips.charge_type != "dynamic" ? var.eips.duration : null

  # Per-group overrides or shared defaults
  bandwidth   = each.value.bandwidth != null ? each.value.bandwidth : var.eips.bandwidth
  charge_mode = each.value.charge_mode != null ? each.value.charge_mode : var.eips.charge_mode

  # Optional
  remark                     = each.value.remark != null ? each.value.remark : null
  share_bandwidth_package_id = var.eips.share_bandwidth_package_id != null ? var.eips.share_bandwidth_package_id : null
}

resource "ucloud_eip_association" "this" {
  for_each = local.associable_eips

  eip_id        = ucloud_eip.this[each.key].id
  resource_id   = each.value.resource_id
  resource_type = each.value.resource_type != null ? each.value.resource_type : "instance"
}
