# Changelog

All notable changes to this module will be documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.0] - 2026-04-29

### Added
- Validation: `share_bandwidth_package_id` is required when `charge_mode = "share_bandwidth"`
- Validation: per-group `charge_mode` override must be a valid enum value

## [1.0.0] - 2026-04-29

### Added
- Initial release
- `ucloud_eip` resource with `for_each` multi-EIP provisioning via `eip_configs` map
- `ucloud_eip_association` resource — auto-associate when `resource_id` is provided
- `overrides` map — per-EIP bandwidth, resource_id, resource_type, remark override
- Shared bandwidth mode support via `charge_mode = share_bandwidth` + `share_bandwidth_package_id`
- Input validation: count >= 1, internet_type/charge_mode/charge_type enums
- Outputs: `eip_ids`, `eip_public_ips`, `eip_statuses`, `association_ids`
- Examples: `basic` (standalone), `complete` (multi-group with instance/lb attachment and overrides)
- GitHub Actions CI: fmt, validate
