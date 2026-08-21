# Changelog

All notable changes to this module will be documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.4.0] - 2026-08-20

### Added
- `max_bandwidth` (default `800`), an upper bound applied to every EIP in the module call and enforced by
  a precondition on `ucloud_eip`. It is a cost guard, not a platform limit: UCloud accepted 300 Mbps with
  `charge_mode = "traffic"`, above the 200 its documentation claims, and takes more than that. Set it to
  the ceiling agreed for the environment so a larger `bandwidth` fails at plan time instead of appearing
  on an invoice.

  It lives in a precondition rather than a `validation` block because it compares two different
  variables, which variable validation cannot do before Terraform 1.9 — and this module supports 1.3.0.

## [1.3.0] - 2026-08-20

### Added
- `associate` flag on `eip_configs` and on `overrides`, deciding whether an EIP is bound.

### Fixed
- An EIP could not be created and bound in the same apply as the instance it attaches to. The
  association's `for_each` was filtered on `resource_id != null`, and that id is unknown at plan time
  while the instance is still being created, so Terraform refused the plan with "Invalid for_each
  argument: local.associable_eips will be known only after apply". `for_each` keys have to be
  resolvable at plan time, values do not — the new `associate` flag keeps the key set static and
  leaves the unknown id in the value.

  Existing configurations are unaffected: with `associate` unset the old inference from `resource_id`
  still applies, which works whenever that id is a literal or a value from a prior apply. Set
  `associate = true` when the id comes from a resource created in the same run.

## [1.2.0] - 2026-04-29

### Added
- Validation: `duration >= 1` when `charge_type` is `month` or `year`

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
