# Ping for static address configuration

Create and bring `tap0` up:

```shell
sudo tunctl -u $USER
sudo ifconfig tap0 192.168.68.116 up
```

Run demo:

```shell
alr run
```
Output:

> Boot
>  64 bytes from 192.168.68.116 seq= 0
>  64 bytes from 192.168.68.116 seq= 1
>  64 bytes from 192.168.68.116 seq= 2
