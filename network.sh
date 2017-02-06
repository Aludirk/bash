################################################################################
# MIT License
#
# Copyright (c) 2017 Aludirk Wong <aludirkwong@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
################################################################################

#!/usr/bin/env bash

pushd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null
source '.core.sh'
source 'dictionary.sh'
source 'message.sh'
source 'string.sh'
popd &> /dev/null

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
function local_ip()
{
  local _lbli_ip_out=${1}

  if [[ -z "${_lbli_ip_out}" ]]; then
    error_code ${LIB_BASH_ERROR_NO_OUTPUT}
    return ${?}
  fi

  _lbli_ifconfig="$(ifconfig 2>/dev/null || exit ${?}; printf "\x1f")"
  local _lbli_ifconfig_exit=${?}
  if [[ ${_lbli_ifconfig_exit} -eq 127 ]]; then
    unset _lbli_ifconfig
    error_code ${LIB_BASH_COMMAND_NOT_FOUND}
    return ${?}
  fi
  if [[ ${_lbli_ifconfig_exit} -ne 0 ]]; then
    unset _lbli_ifconfig
    error_code ${LIB_BASH_INTERNAL_ERROR}
    return ${?}
  fi

  # Capture all network interfaces.
  local _lbli_matched=()
  local _lbli_group=()
  regex_string "${_lbli_ifconfig%$'\x1f'}" '^(\w+): (.*?\n(?!\s))' 'gms' _lbli_matched _lbli_group
  if [[ ${?} -ne 0 ]]; then
    unset _lbli_ifconfig
    error_code ${LIB_BASH_INTERNAL_ERROR}
    return ${?}
  fi
  unset _lbli_ifconfig

  # Capture the IPv4 IP.
  local _lbli_group_count=${#_lbli_group[@]}
  local _lbli_index=0
  local _lbli_ip_dict
  dict_init _lbli_ip_dict
  until [[ ${_lbli_index} -ge ${_lbli_group_count} ]]; do
    local _lbli_interface="${_lbli_group[${_lbli_index}]}"
    local _lbli_ip_matched=''
    local _lbli_ip=()
    regex_string \
      "${_lbli_group[$[_lbli_index + 1]]}" \
      'inet ((?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))\b' \
      '' \
      _lbli_ip_matched \
      _lbli_ip
    if [[ ${#_lbli_ip[@]} -gt 0 ]] \
    && [[ -n "${_lbli_ip[0]}" ]] \
    && [[ "${_lbli_ip[0]}" != '127.0.0.1' ]]; then
      dict_set "${_lbli_ip_dict}" "${_lbli_interface}" "${_lbli_ip[0]}"
    fi

    ((++_lbli_index))
    ((++_lbli_index))
  done

  local _lbli_ip_count=0
  dict_count "${_lbli_ip_dict}" _lbli_ip_count
  if [[ ${_lbli_ip_count} -eq 0 ]]; then
    # No IP found.
    eval "${_lbli_ip_out}=''"
  elif [[ ${_lbli_ip_count} -eq 1 ]]; then
    # 1 IP found.
    local _lbli_ip=()
    dict_values "${_lbli_ip_dict}" _lbli_ip
    eval "${_lbli_ip_out}='${_lbli_ip[0]}'"
  else
    # Multiple IPs found.
    local _lbli_interfaces=()
    dict_keys "${_lbli_ip_dict}" _lbli_interfaces

    local _lbli_ips=()
    dict_values "${_lbli_ip_dict}" _lbli_ips

    local _lbli_options=()
    local _lbli_index=0
    for _lbli_index in $(seq 0 $[_lbli_ip_count - 1]); do
      _lbli_options+=("${_lbli_interfaces[${_lbli_index}]}: ${_lbli_ips[${_lbli_index}]}")
    done

    local _lbli_selected_index=0
    select_option \
      'Multiple network interfaces are found, please select one for local network:' \
      _lbli_options[@] \
      _lbli_selected_index
    eval "${_lbli_ip_out}='${_lbli_ips[${_lbli_selected_index}]}'"
  fi

  dict_destroy "${_lbli_ip_dict}"

  return 0
}
