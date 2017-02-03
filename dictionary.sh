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
source 'string.sh'
popd &> /dev/null

################################################################################
# Check whether the dictionary key is valid.
#
# Usage: _dict_check_key <key> <is_valid>
#
# Parameters:
#   key      [in]  The key to check, it must be alphabet or digit or underscore.
#   is_valid [out] Whether the key is valid.
#
# Returns:
#   ${LIB_BASH_ERROR_INVALID_PARAM}
#   ${LIB_BASH_ERROR_NO_OUTPUT}
################################################################################
function _dict_check_key()
{
  local _lbdck_key="${1}"
  local _lbdck_out=${2}

  if [[ ${#} -lt 1 ]]; then
    error_code ${LIB_BASH_ERROR_INVALID_PARAM}
    return ${?}
  fi

  if [[ -z "${_lbdck_out}" ]]; then
    error_code ${LIB_BASH_ERROR_NO_OUTPUT}
    return ${?}
  fi

  local _lbdck_is_match=false
  match_string "${_lbdck_key}" '[a-zA-Z0-9_]+' '' _lbdck_is_match
  if [[ ${_lbdck_is_match} == true ]]; then
    eval "${_lbdck_out}=true"
  else
    eval "${_lbdck_out}=false"
  fi

  return 0
}

################################################################################
# Initialize dictionary.
#
# Usage: dict_init <dict_out>
#
# Parmeters:
#   dict_out [out] The initialized dictionary, should use `dict_destroy` to
#                  destroy.
#
# Returns:
#   ${LIB_BASH_ERROR_NO_OUTPUT}
################################################################################
function dict_init()
{
  local _lbdi_dict_out=${1}

  if [[ -z "${_lbdi_dict_out}" ]]; then
    error_code ${LIB_BASH_ERROR_NO_OUTPUT}
    return ${?}
  fi

  local _lbdi_dict=''
  until [[ -n "${_lbdi_dict}" ]]; do
    local _lbdi_name="$(printf '__dict__%d%d' $(date +%s) ${RANDOM})"
    if [[ ! ${!_lbdi_name+x} ]]; then
      _lbdi_dict="${_lbdi_name}"
    fi
  done

  eval "${_lbdi_dict}=' '"
  eval "${_lbdi_dict_out}=\"\${_lbdi_dict}\""

  return 0
}

################################################################################
# Destroy dictionary.
#
# Usage: dict_destroy <dict>
#
# Parameters:
#   dict [in] The dictionary to destroy.
#
# Returns:
#   ${LIB_BASH_ERROR_INVALID_PARAM}
################################################################################
function dict_destroy()
{
  local _lbdd_dict="${1}"

  if [[ ${#} -lt 1 ]]; then
    error_code ${LIB_BASH_ERROR_INVALID_PARAM}
    return ${?}
  fi

  if [[ ${!_lbdd_dict+x} ]]; then
    dict_clear "${_lbdd_dict}"
    eval "unset ${_lbdd_dict}"
  fi

  return 0
}

################################################################################
# Retrieve the value from the dictionary.
#
# Usage: dict_get <dict> <key> <value_out>
#
# Parameters:
#   dict      [in]  The dictionary for operation.
#   key       [in] The key for the value to get.
#   value_out [out] The value.
#
# Returns:
#   ${LIB_BASH_ERROR_INVALID_PARAM}
#   ${LIB_BASH_ERROR_NO_OUTPUT}
################################################################################
function dict_get()
{
  local _lbdg_dict="${1}"
  local _lbdg_key="${2}"
  local _lbdg_value_out=${3}

  if [[ ${#} -lt 2 ]] \
  || [[ ! ${!_lbdg_dict+x} ]]; then
    error_code ${LIB_BASH_ERROR_INVALID_PARAM}
    return ${?}
  fi

  if [[ -z "${_lbdg_value_out}" ]]; then
    error_code ${LIB_BASH_ERROR_NO_OUTPUT}
    return ${?}
  fi

  eval "${_lbdg_value_out}=''"

  local _lbdg_is_match=false
  _dict_check_key "${_lbdg_key}" _lbdg_is_match
  if [[ ${_lbdg_is_match} == false ]]; then
    # no ops
    return 0
  fi

  eval "
case \${${_lbdg_dict}} in
  *' ${_lbdg_key} '*) ${_lbdg_value_out}=\${${_lbdg_dict}__${_lbdg_key}};;
esac"

  return 0
}

################################################################################
# Set the value for the dictionary.
#
# Usage: dict_set <dict> <key> <value>
#
# Parameters:
#   dict  [in] The dictionary for operation.
#   key   [in] The key for the value to set, it must be alphabet or digit or
#              underscore.
#   value [in] The new value.
#
# Returns:
#   ${LIB_BASH_ERROR_INVALID_PARAM}
################################################################################
function dict_set()
{
  local _lbds_dict="${1}"
  local _lbds_key="${2}"

  local _lbds_value
  printf -v _lbds_value '%b' "${3}"

  if [[ ${#} -lt 3 ]] || [[ ! ${!_lbds_dict+x} ]]; then
    error_code ${LIB_BASH_ERROR_INVALID_PARAM}
    return ${?}
  fi

  local _lbds_is_match=false
  _dict_check_key "${_lbds_key}" _lbds_is_match
  if [[ ${_lbds_is_match} == false ]]; then
    error_code ${LIB_BASH_ERROR_INVALID_PARAM}
    return ${?}
  fi

  eval "
${_lbds_dict}__${_lbds_key}=\"\${_lbds_value}\"
case \"\${${_lbds_dict}}\" in
  *' ${_lbds_key} '*) :;;
  *) ${_lbds_dict}=\"\${${_lbds_dict}}${_lbds_key} \";;
esac"

  return 0
}

################################################################################
# Unset the value from the dictionary.
#
# Usage: dict_unset <dict> <key>
#
# Parameters:
#   dict [in] The dictionary for operation.
#   key  [in] The key for the value to unset.
#
# Returns:
#   ${LIB_BASH_ERROR_INVALID_PARAM}
################################################################################
function dict_unset()
{
  local _lbdu_dict="${1}"
  local _lbdu_key="${2}"

  if [[ ${#} -lt 2 ]] || [[ ! ${!_lbdu_dict+x} ]]; then
    error_code ${LIB_BASH_ERROR_INVALID_PARAM}
    return ${?}
  fi

  local _lbdu_is_match=false
  _dict_check_key "${_lbdu_key}" _lbdu_is_match
  if [[ ${_lbdu_is_match} == false ]]; then
    # no ops
    return 0
  fi

  eval "
case \"\${${_lbdu_dict}}\" in
  *' ${_lbdu_key} '*)
    unset ${_lbdu_dict}__${_lbdu_key}
    ${_lbdu_dict}=\"\${${_lbdu_dict}% ${_lbdu_key} *} \${${_lbdu_dict}#* ${_lbdu_key} }\";;
esac"

  return 0
}

################################################################################
# Clear all elements in dictionary.
#
# Usage: dict_clear <dict>
#
# Parameters:
#   dict [in] The dictionary for operation.
#
# Returns:
#   ${LIB_BASH_ERROR_INVALID_PARAM}
#   ${LIB_BASH_INTERNAL_ERROR}
################################################################################
function dict_clear()
{
  local _lbdc_dict="${1}"

  if [[ ${#} -lt 1 ]] || [[ ! ${!_lbdc_dict+x} ]]; then
    error_code ${LIB_BASH_ERROR_INVALID_PARAM}
    return ${?}
  fi

  local _lbdc_keys=()
  dict_keys "${_lbdc_dict}" _lbdc_keys
  if [[ ${?} -ne 0 ]]; then
    error_code ${LIB_BASH_INTERNAL_ERROR}
    return ${?}
  fi

  local _lbdc_key=''
  for _lbdc_key in "${_lbdc_keys[@]}"; do
    dict_unset "${_lbdc_dict}" "${_lbdc_key}"
  done

  return 0
}

################################################################################
# Retrieve the number of element of the dictionary.
#
# Usage: dict_count <dict> <count_out>
#
# Parameters:
#   dict      [in]  The dictionary for operation.
#   count_out [out] The number of element.
#
# Returns:
#   ${LIB_BASH_ERROR_INVALID_PARAM}
#   ${LIB_BASH_ERROR_NO_OUTPUT}
################################################################################
function dict_count()
{
  local _lbdc_dict="${1}"
  local _lbdc_count_out=${2}

  if [[ ${#} -lt 1 ]] || [[ ! ${!_lbdc_dict+x} ]]; then
    error_code ${LIB_BASH_ERROR_INVALID_PARAM}
    return ${?}
  fi

  if [[ -z "${_lbdc_count_out}" ]]; then
    error_code ${LIB_BASH_ERROR_NO_OUTPUT}
    return ${?}
  fi

  # Remove all non-spaces.
  eval "local _lbdc_dict_str=\"\${${_lbdc_dict}}\""
  replace_string "${_lbdc_dict_str}" '[^ ]' '' 'g' _lbdc_dict_str

  # Count the number of space.
  local _lbdc_count=${#_lbdc_dict_str}
  eval "${_lbdc_count_out}=$[_lbdc_count - 1]"

  return 0
}

################################################################################
# Retrieve the array of the keys in dictionary.
#
# Usage: dict_keys <dict> <keys_out>
#
# Parameters:
#   dict     [in]  The dictionary for operation.
#   keys_out [out] The array of the keys.
#
# Returns:
#   ${LIB_BASH_ERROR_INVALID_PARAM}
#   ${LIB_BASH_ERROR_NO_OUTPUT}
################################################################################
function dict_keys()
{
  local _lbdk_dict="${1}"
  local _lbdk_keys_out=${2}

  if [[ ${#} -lt 1 ]] || [[ ! ${!_lbdk_dict+x} ]]; then
    error_code ${LIB_BASH_ERROR_INVALID_PARAM}
    return ${?}
  fi

  if [[ -z "${_lbdk_keys_out}" ]]; then
    error_code ${LIB_BASH_ERROR_NO_OUTPUT}
    return ${?}
  fi

  eval "${_lbdk_keys_out}=(\${${_lbdk_dict}})"

  return 0
}

################################################################################
# Retrieve the array of the values in dictionary.
#
# Usage: dict_values <dict> <values_out>
#
# Parameters:
#   dict       [in]  The dictionary for operation.
#   values_out [out] The array of the values.
#
# Returns:
#   ${LIB_BASH_ERROR_INVALID_PARAM}
#   ${LIB_BASH_ERROR_NO_OUTPUT}
#   ${LIB_BASH_INTERNAL_ERROR}
################################################################################
function dict_values()
{
  local _lbdv_dict="${1}"
  local _lbdv_values_out=${2}

  if [[ ${#} -lt 1 ]] || [[ ! ${!_lbdv_dict+x} ]]; then
    error_code ${LIB_BASH_ERROR_INVALID_PARAM}
    return ${?}
  fi

  if [[ -z "${_lbdv_values_out}" ]]; then
    error_code ${LIB_BASH_ERROR_NO_OUTPUT}
    return ${?}
  fi

  local _lbdv_keys=()
  dict_keys "${_lbdv_dict}" _lbdv_keys
  if [[ ${?} -ne 0 ]]; then
    error_code ${LIB_BASH_INTERNAL_ERROR}
    return ${?}
  fi

  eval "${_lbdv_values_out}=()"

  local _lbdv_key=''
  for _lbdv_key in "${_lbdv_keys[@]}"; do
    local _lbdv_value=''
    dict_get "${_lbdv_dict}" "${_lbdv_key}" _lbdv_value

    _lbdv_value="$(printf "%s\x1f" "${_lbdv_value}" | escape_system)"
    eval "${_lbdv_values_out}+=(\"${_lbdv_value%$'\x1f'}\")"
  done

  return 0
}
