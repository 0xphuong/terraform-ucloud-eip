# terraform-ucloud-eip

Terraform module to create **Elastic IPs** and optional **EIP Associations** on [UCloud](https://www.ucloud.cn).

## Features

- Creates multiple EIPs via a map-based config
- Optional association to instances, load balancers, NAT gateways, etc.
- `overrides` for per-EIP config (bandwidth, resource_id, resource_type)
- Binds an EIP to an instance created in the same apply, via an explicit `associate` flag
- Supports shared bandwidth mode (`share_bandwidth`)
- Structured outputs: EIP IDs, public IPs, statuses, association IDs

## Usage

### Basic — standalone EIPs

```hcl
module "eip" {
  source = "github.com/0xphuong/terraform-ucloud-eip?ref=v1.0.0"

  eips = {
    internet_type = "bgp"
    charge_mode   = "bandwidth"
    bandwidth     = 10

    eip_configs = {
      web-eip = {
        count = 2
      }
    }
  }
}
```

### Attach to instance

```hcl
eip_configs = {
  gateway = {
    count         = 1
    bandwidth     = 100
    resource_id   = var.instance_id
    resource_type = "instance"
  }
}
```

### Per-EIP override (different instances)

```hcl
eip_configs = {
  app = {
    count = 3
    overrides = {
      "0" = { resource_id = var.app_ids[0] }
      "1" = { resource_id = var.app_ids[1] }
      "2" = { resource_id = var.app_ids[2] }
    }
  }
}
```

### Shared bandwidth mode

```hcl
eips = {
  internet_type              = "bgp"
  charge_mode                = "share_bandwidth"
  bandwidth                  = 0
  share_bandwidth_package_id = "bwpack-xxxxx"

  eip_configs = {
    shared = { count = 3 }
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |
| ucloud | >= 1.39.5 |

## Providers

| Name | Version |
|------|---------|
| ucloud | >= 1.39.5 |

## Resources

| Name | Type |
|------|------|
| ucloud_eip.this | resource |
| ucloud_eip_association.this | resource |

## Binding to a resource created in the same apply

`for_each` keys must be resolvable at plan time. Leaving `associate` unset makes the module infer the
binding from `resource_id`, which is fine for a literal id or one from a previous apply — but not for an
instance being created in the same run, where the id is still unknown and Terraform refuses the plan with
`Invalid for_each argument`.

Set the flag explicitly in that case:

```hcl
eip_configs = {
  web = {
    count       = 1
    associate   = true
    resource_id = module.host.instance_ids["web-0"]
  }
}
```

## Cost guard

`max_bandwidth` caps every `bandwidth` in the module call and fails the plan when one exceeds it:

```hcl
module "eip" {
  source        = "github.com/0xphuong/terraform-ucloud-eip?ref=v1.4.0"
  max_bandwidth = 300
  ...
}
```

This is a billing ceiling, not a platform one — UCloud accepted 300 Mbps on `charge_mode = "traffic"`,
above the 200 its docs claim, and takes more. Default is `800`.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| eips | Shared EIP params + per-group configurations | `object` | — | **yes** |

### `eips` object

| Field | Type | Default | Required | Description |
|-------|------|---------|----------|-------------|
| `max_bandwidth` | `number` | `800` | no | Upper bound enforced on every EIP bandwidth |
| `internet_type` | `string` | — | **yes** | `bgp` \| `international` |
| `charge_mode` | `string` | `"bandwidth"` | no | `traffic` \| `bandwidth` \| `share_bandwidth` |
| `charge_type` | `string` | `"month"` | no | `month` \| `year` \| `dynamic` |
| `duration` | `number` | `1` | no | Purchase duration |
| `bandwidth` | `number` | `1` | no | Default bandwidth in Mbps |
| `tag` | `string` | `"Default"` | no | Tag for all EIPs |
| `share_bandwidth_package_id` | `string` | `null` | no | Required when `charge_mode = share_bandwidth` |
| `eip_configs` | `map(object)` | — | **yes** | Per-group EIP configuration |

### `eip_configs` map value

| Field | Type | Default | Required | Description |
|-------|------|---------|----------|-------------|
| `count` | `number` | — | **yes** | Number of EIPs to create |
| `bandwidth` | `number` | `null` | no | Override bandwidth for this group |
| `charge_mode` | `string` | `null` | no | Override charge mode for this group |
| `remark` | `string` | `null` | no | EIP remark |
| `associate` | `bool` | `null` | no | Whether to bind the EIP. Unset infers it from `resource_id` |
| `resource_id` | `string` | `null` | no | Resource ID to associate. Omit to create unattached EIP |
| `resource_type` | `string` | `"instance"` | no | `instance` \| `lb` \| `natgw` \| `udb` \| `vpngw` \| `baremetal` |
| `overrides` | `map(object)` | `{}` | no | Per-EIP overrides, key = EIP index string |

### `overrides` map value (all optional)

| Field | Description |
|-------|-------------|
| `bandwidth` | Override bandwidth for this EIP |
| `associate` | Override whether this EIP is bound |
| `resource_id` | Override resource to associate for this EIP |
| `resource_type` | Override resource type for this EIP |
| `remark` | Override remark for this EIP |

## Outputs

| Name | Description |
|------|-------------|
| eip\_ids | Map of EIP key => EIP ID |
| eip\_public\_ips | Map of EIP key => public IP address |
| eip\_statuses | Map of EIP key => EIP status |
| association\_ids | Map of EIP key => associated resource ID (only bound EIPs) |
<!-- END_TF_DOCS -->

## Examples

- [Basic](./examples/basic) — 2 standalone EIPs
- [Complete](./examples/complete) — standalone, attached, per-EIP override, load balancer

## Changelog

See [CHANGELOG.md](./CHANGELOG.md).

## License

[MIT](./LICENSE)
