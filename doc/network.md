# Module - Network

Network utility.

* [local_ip](#local_ip)

## local_ip

```
################################################################################
# Retrieve the local IP (IPv4) from `ifconfig`.
#
# Usage: local_ip <ip_out>
#
# Parameters:
#   ip_out [out] The found IPv4 IP for local machine, if no IP is found, empty
#                string will be returned.  If 1 IP is found, the IP will be
#                returned.  If multiple IPs are found, a question will ask for
#                selecting and return it.  127.0.0.1 will not be returned.
#
# Returns:
#   ${LIB_BASH_ERROR_NO_OUTPUT}
#   ${LIB_BASH_INTERNAL_ERROR}
#   ${LIB_BASH_COMMAND_NOT_FOUND}
#
# The IP (IPv4 only) is grepped from `ifconfig`, if `ifconfig` does not exist,
# the function will return ${LIB_BASH_COMMAND_NOT_FOUND}.
################################################################################
```

Examples:
```bash
# No IPv4 found.
local_ip ip

printf "IP: ${ip}\n"
###
# IP: 
###
```

```bash
# 1 IPv4 found.
local_ip ip

printf "IP: ${ip}\n"
###
# IP: 192.168.10.100
###
```

```bash
# Multiple IPv4s found.  Question will be asked.
local_ip ip

printf "IP: ${ip}\n"
###
# Multiple network interfaces are found, please select one for local network:
#   1) en0: 192.168.10.100
#   2) vboxnet0: 10.10.10.1
# 1-2 ? 2
# IP: 10.10.10.1
###
```
