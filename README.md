enet_tap
========

> Ethernet driver implementation over TUN/TAP device and 
[ada-enet](https://github.com/stcarrez/ada-enet) IP stack.

This driver has been tested on Linux x86_86.

## Install

Add `enet_tap` as a dependency to your crate with Alire:

    alr with enet_tap

## Usage

Create TAP device on your machine, configure it and start DHCP daemon if needed.

```shell
# Create tap interface for the user
sudo tunctl -u $USER
# Set 'tap0' persistent and owned by uid 1000
# Bring tap0 interface up
sudo ifconfig tap0 192.168.0.254 up
# Launch DHCP server on tap0 interface
sudo dnsmasq --no-daemon --log-debug --interface=tap0 --dhcp-range=192.168.0.2,192.168.0.7 --port=0  --bind-interfaces
```

Create the interface and configure it providing TAP device name:

```ada
   MAC : aliased Net.Interfaces.Tap.Tap_Ifnet;
begin
   MAC.Create (Tap => "tap0");
```

## Examples

1. `ping`. See complete example in `demos/ping`.

```shell
$ ./bin/ping 
Boot
STATE_SELECTING
STATE_REQUESTING
STATE_DAD
STATE_BOUND
192.168.0.2
 64 bytes from 192.168.0.254 seq= 0
 64 bytes from 192.168.0.254 seq= 1
 64 bytes from 192.168.0.254 seq= 2
```

## Maintainer

[@Max Reznik](https://github.com/reznikmm).

## Contribute

[Open an issue](https://github.com/reznikmm/enet_tap/issues/new)
or submit PRs.

## License

[Apache-2.0 WITH LLVM-exception](LICENSES/) © Max Reznik
