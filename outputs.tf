output "eip_ids" {
  description = "Map of EIP key => EIP ID"
  value       = { for k, e in ucloud_eip.this : k => e.id }
}

output "eip_public_ips" {
  description = "Map of EIP key => public IP address"
  value       = { for k, e in ucloud_eip.this : k => e.public_ip }
}

output "eip_statuses" {
  description = "Map of EIP key => EIP status"
  value       = { for k, e in ucloud_eip.this : k => e.status }
}

output "association_ids" {
  description = "Map of EIP key => associated resource ID (only bound EIPs)"
  value       = { for k, a in ucloud_eip_association.this : k => a.resource_id }
}
