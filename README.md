# loop-lvm-cookbook

Cookbook to set up LVM on a loopback device

## Supported Platforms

Centos 6.5

## Usage

### loop-lvm::default

Include `loop-lvm` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[loop-lvm::default]"
  ]
}
```

## License and Authors

Author:: Venkat Venkataraju (<venkat.venkataraju@yahoo.com>)
