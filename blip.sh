#!/bin/bash
# Author: Yevgeniy Goncharov aka xck, http://sys-adm.in
# Create blackhole route for IP list or single IP

# Sys env / paths / etc
# -------------------------------------------------------------------------------------------\
PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
SCRIPT_PATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)

# Variables
# -------------------------------------------------------------------------------------------\
# Gateway and interface for blackhole route
GATEWAY="127.0.0.1"
INTERFACE="lo"

# Functions
# -------------------------------------------------------------------------------------------\
# Check for root
# if [ "$(id -u)" != "0" ]; then
#   echo "For run this script you need root access."
#   exit 1
# fi

# Check file exists function
check_file() {
  if [ ! -f "$1" ]; then
    echo "File '$1' not found."
    exit 1
  fi
}

# Read IP list from file and pass to add_route function
read_ip_list() {
  local IP_LIST="$1"
  check_file "$IP_LIST"

  while IFS= read -r line; do
    add_route "$line"
  done < "$IP_LIST"
}

# Check if ip command exists and return true or false
check_ip_command() {
  if [ -x "$(command -v ip)" ]; then
    return 0
  else
    return 1
  fi
}

# Add to route function
add_route() {
  # Check for IP
  if [[ $1 =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    local ip="$1"
    if check_ip_command; then
      ip route add "$ip" via "$GATEWAY" dev "$INTERFACE"
      echo "Added route for $ip"
    fi
    # echo "Added route for $ip"
  elif [[ $1 =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}$ ]]; then
    local ip="$1"
    if check_ip_command; then
      ip route add "$ip" via "$GATEWAY" dev "$INTERFACE"
      echo "Added route for $ip"
    fi
    # echo "Added route for $ip"
  else
    echo "String '$1' is not a valid IP address."
  fi
}

# Check for arguments --file or --ip
if [ $# -eq 0 ]; then
  echo "Usage: $0 --file <file_with_ip_list> or $0 --ip <ip_address>"
  exit 1
fi

# Processing arguments with while
while [[ $# -gt 0 ]]; do
  case "$1" in
    --file)
      shift
      IP_LIST="$1"
      read_ip_list "$IP_LIST"  
      ;;
    --ip)
      shift
      add_route "$1"
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
  shift
done
