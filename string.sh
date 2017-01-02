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

pushd $(dirname "${BASH_SOURCE[0]}") &> /dev/null
source ".core.sh"
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

  if [[ ${#} -lt 2 ]] || [[ -z "${_lbis_sep}" ]]; then
    error_code ${LIB_BASH_ERROR_INVALID_PARAM}
    return ${?}
  fi

  if [[ -z "${_lbis_array_out}" ]]; then
    error_code ${LIB_BASH_ERROR_NO_OUTPUT}
    return ${?}
  fi

  # Subsitute the front of each element in ${_lbis_pop_first_array} with
  # ${_lbis_sep}
  printf -v "${_lbis_array_out}" "%s" \
    "${_lbis_first_element}${_lbis_pop_first_array[@]/#/$_lbis_sep}"

  return 0
}

################################################################################
# Explode a string to array.
#
# Usage: explode_string <string> <dilimiter> <array_out>
#
# Parameters:
#   string    [in]  The string to explode.
#   dilimiter [in]  The dilimiter list (for IFS (internal field separator) use).
#   array_out [out] The exploded array.
#
# Returns:
#   ${LIB_BASH_ERROR_INVALID_PARAM}
#   ${LIB_BASH_ERROR_NO_OUTPUT}
################################################################################
function explode_string()
{
  local _lbes_string="${1}"
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
    eval "${_lbes_array_out}+=(\"${_lbes_value}\")"
  done

  return 0
}
