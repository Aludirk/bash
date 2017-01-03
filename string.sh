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
source ".core.sh"
source "command.sh"
popd &> /dev/null

################################################################################
# Implode an array to string.
#
# Usage: implode_string <string_array> <separator> <string_out>
#
# Parameters:
#   string_array [in]  The array of string to implode.
#   separator    [in]  The separator.
#   string_out   [out] The imploded string.
#
# Returns:
#   ${LIB_BASH_ERROR_INVALID_PARAM}
#   ${LIB_BASH_ERROR_NO_OUTPUT}
################################################################################
function implode_string()
{
  local _lbis_array=("${!1}")
  local _lbis_first_element="${_lbis_array[0]}"
  local _lbis_pop_first_array=("${_lbis_array[@]:1}")
  local _lbis_sep="${2}"
  local _lbis_array_out=${3}

  if [[ ${#} -lt 2 ]]; then
    error_code ${LIB_BASH_ERROR_INVALID_PARAM}
    return ${?}
  fi

  if [[ -z "${_lbis_array_out}" ]]; then
    error_code ${LIB_BASH_ERROR_NO_OUTPUT}
    return ${?}
  fi

  # Subsitute the front of each element in ${_lbis_pop_first_array} with
  # ${_lbis_sep}
  printf -v "${_lbis_array_out}" "%b" \
    "${_lbis_first_element}${_lbis_pop_first_array[@]/#/$_lbis_sep}"

  return 0
}

################################################################################
# Explode a string to array.
#
# Usage: explode_string <string> <delimiter> <array_out>
#
# Parameters:
#   string    [in]  The string to explode.
#   delimiter [in]  The delimiter list (for IFS (internal field separator) use).
#   array_out [out] The exploded array.
#
# Returns:
#   ${LIB_BASH_ERROR_INVALID_PARAM}
#   ${LIB_BASH_ERROR_NO_OUTPUT}
################################################################################
function explode_string()
{
  local _lbes_string="$(printf "%b" "${1}")"
  local _lbes_IFS=${2}
  local _lbes_array_out=${3}

  if [[ ${#} -lt 2 ]] || [[ -z "${_lbes_IFS}" ]]; then
    error_code ${LIB_BASH_ERROR_INVALID_PARAM}
    return ${?}
  fi

  if [[ -z "${_lbes_array_out}" ]]; then
    error_code ${LIB_BASH_ERROR_NO_OUTPUT}
    return ${?}
  fi

  # Clean up the result.
  eval "${_lbes_array_out}=()"

  IFS=${_lbes_IFS}
  local _lbes_tmp_array_out=(${_lbes_string})
  IFS="${LIB_BASH_ORIGINAL_IFS}"

  # Push all outputs to result array.
  local _lbes_value
  for _lbes_value in "${_lbes_tmp_array_out[@]}"; do
    _lbes_value="$(printf "%b" "${_lbes_value}" | escape_system)"
    eval "${_lbes_array_out}+=(\"${_lbes_value}\")"
  done

  return 0
}

################################################################################
# Escape the string.
#
# Usage: escape_string [-e escape_list] <string> <escaped_string>
#
# Options:
#   -s escape_list The character list for escaping, default is '"\$'.
#
# Parameters:
#  string         [in]  The string to escape.
#  escaped_string [out] The escaped string.
#
# Returns:
#   ${LIB_BASH_ERROR_INVALID_PARAM}
#   ${LIB_BASH_ERROR_INVALID_OPTION}
#   ${LIB_BASH_ERROR_NO_OUTPUT}
################################################################################
function escape_string()
{
  local _lbes_args=("${@}")
  local _lbes_options=()
  local _lbes_params=()

  get_option "e:" _lbes_args[@] _lbes_options _lbes_params
  if [[ ${?} -ne 0 ]]; then
    error_code ${LIB_BASH_ERROR_INVALID_OPTION}
    return ${?}
  fi

  local _lbes_output=""
  if [[ ${#_lbes_params[@]} -lt 1 ]]; then
    error_code ${LIB_BASH_ERROR_INVALID_PARAM}
    return ${?}
  else
    _lbes_output="${_lbes_params[0]}"
  fi

  local _lbes_escaped_string
  if [[ ${#_lbes_params[@]} -lt 2 ]] || [[ -z "${_lbes_params[1]}" ]]; then
    error_code ${LIB_BASH_ERROR_NO_OUTPUT}
    return ${?}
  else
    _lbes_escaped_string=${_lbes_params[1]}
  fi

  local _lbes_escape_list='"$\'
  local _lbes_option=""
  for _lbes_option in "${_lbes_options[@]}"; do
    local _lbes_opt=""
    local _lbes_data=""

    parse_option "${_lbes_option}" _lbes_opt _lbes_data
    case "${_lbes_opt}" in
      e) _lbes_escape_list="${_lbes_data}";;
    esac
  done

  _lbes_output="$(printf "%b" "${_lbes_output}" | sed 's/\(['"${_lbes_escape_list}"']\)/\\\1/g')"
  eval "${_lbes_escaped_string}=\"\$(printf \"%s\" \"\${_lbes_output}\")\""

  return 0
}
