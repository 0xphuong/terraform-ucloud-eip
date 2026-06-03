# Create 2 standalone EIPs (no attachment)
module "eip" {
  source = "github.com/0xphuong/terraform-ucloud-eip?ref=v1.0.0"

  eips = {
    internet_type = "bgp"
    charge_mode   = "bandwidth"
    bandwidth     = 10
    tag           = "basic"

    eip_configs = {
      web-eip = {
        count = 2
      }
    }
  }
}

output "eip_ids"        { value = module.eip.eip_ids }
output "eip_public_ips" { value = module.eip.eip_public_ips }
