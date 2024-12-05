# Blackhole IP Script

Directs traffic to a nonexistent interface, with dropping the packets. 

Uses internal `ip` command, example usage:

```bash
ip route add <subnet> via 127.0.0.1 dev lo
```

## Script usage

Usage with list of IPs:
```bash
./blip.sh --file ips.txt 
```

or for single IP:
```bash
./blip.sh --ip xxx.xxx.xx.xx
```
