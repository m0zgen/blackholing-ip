#!/bin/bash
# Author: Yevgeniy Goncharov aka xck, http://sys-adm.in
# Create blackhole route for IP list or single IP

PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
SCRIPT_PATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)

GATEWAY="127.0.0.1"
INTERFACE="lo"

check_file() {
  if [ ! -f "$1" ]; then
    echo "File '$1' not found."
    exit 1
  fi
}

check_ip_command() {
  if [ -x "$(command -v ip)" ]; then
    return 0
  else
    return 1
  fi
}

add_route() {
  local ip="$1"
  if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]] || \
     [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}$ ]]; then
    if check_ip_command; then
      ip route add ${ip} via ${GATEWAY} dev ${INTERFACE}
      echo "Added route for $ip"
    fi
  else
    echo "String '$ip' is not a valid IP address."
  fi
}

del_route() {
  local ip="$1"
  if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]] || \
     [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}$ ]]; then
    if check_ip_command; then
      ip route del ${ip} via ${GATEWAY} dev ${INTERFACE}
      echo "Deleted route for $ip"
    fi
  else
    echo "String '$ip' is not a valid IP address."
  fi
}

read_ip_list() {
  local IP_LIST="$1"
  check_file "$IP_LIST"
  while IFS= read -r line; do
    add_route "$line"
  done < "$IP_LIST"
}

delete_ip_list() {
  local IP_LIST="$1"
  check_file "$IP_LIST"
  while IFS= read -r line; do
    del_route "$line"
  done < "$IP_LIST"
}

if [ $# -eq 0 ]; then
  echo "Usage:"
  echo "  $0 --file <file_with_ip_list>         # Add routes from file"
  echo "  $0 --ip <ip_address>                  # Add single IP"
  echo "  $0 --delete-file <file_with_ip_list>  # Delete routes from file"
  echo "  $0 --delete-ip <ip_address>           # Delete single IP"
  exit 1
fi

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
    --delete-ip)
      shift
      del_route "$1"
      ;;
    --delete-file)
      shift
      delete_ip_list "$1"
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
  shift
done