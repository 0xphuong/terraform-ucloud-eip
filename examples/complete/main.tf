module "eip" {
  source = "github.com/0xphuong/terraform-ucloud-eip?ref=v1.0.0"

  eips = {
    internet_type = "bgp"
    charge_mode   = "bandwidth"
    charge_type   = "month"
    bandwidth     = 10
    tag           = "production"

    eip_configs = {

      # ── Use case 1: Standalone EIPs (no attachment) ────────────────
      spare = {
        count  = 2
        remark = "spare EIPs for future use"
      }

      # ── Use case 2: Attach all EIPs to the same instance ──────────
      gateway = {
        count         = 2
        bandwidth     = 100
        resource_id   = var.gateway_instance_id
        resource_type = "instance"
      }

      # ── Use case 3: Per-EIP override (different instances) ─────────
      # Each EIP attaches to a different instance via overrides
      app = {
        count = 3
        overrides = {
          "0" = { resource_id = var.app_instance_ids[0] }
          "1" = { resource_id = var.app_instance_ids[1] }
          "2" = { resource_id = var.app_instance_ids[2] }
        }
      }

      # ── Use case 4: Higher bandwidth for specific EIP ──────────────
      lb = {
        count     = 2
        bandwidth = 50   # default bandwidth
        overrides = {
          "0" = { bandwidth = 200 }  # lb-0 gets higher bandwidth
        }
        resource_id   = var.lb_id
        resource_type = "lb"
      }
    }
  }
}

output "eip_ids"         { value = module.eip.eip_ids }
output "eip_public_ips"  { value = module.eip.eip_public_ips }
output "eip_statuses"    { value = module.eip.eip_statuses }
output "association_ids" { value = module.eip.association_ids }
