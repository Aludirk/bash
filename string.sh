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
source 'command.sh'
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
  printf -v "${_lbis_array_out}" '%b' \
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
  local _lbes_string="$(printf "%b\x1f" "${1}" | escape_perl)"
  local _lbes_IFS="$(printf "%b\x1f" "${2}" | escape_perl_re)"
  local _lbes_array_out=${3}

  if [[ ${#} -lt 2 ]]; then
    error_code ${LIB_BASH_ERROR_INVALID_PARAM}
    return ${?}
  fi

  if [[ -z "${_lbes_array_out}" ]]; then
    error_code ${LIB_BASH_ERROR_NO_OUTPUT}
    return ${?}
  fi

  # Clean up the result.
  eval "${_lbes_array_out}=()"

  local _lbes_perl_out=''
  if [[ "${_lbes_IFS}" == $'\x1f' ]]; then
    _lbes_perl_out="$(perl -CS -e \
                      'use utf8;
                       print join("\x1e",
                                  split(//, "'"${_lbes_string%$'\x1f'}"'"))';
                      printf "\x1f")"
  else
    _lbes_perl_out="$(perl -CS -e \
                      'use utf8;
                       print join("\x1e",
                                  split(/['"${_lbes_IFS%$'\x1f'}"']/,
                                        "'"${_lbes_string%$'\x1f'}"'",
                                        -1))';
                      printf "\x1f")"
  fi
  IFS=$'\x1e'
  local _lbes_perl_array=(${_lbes_perl_out})
  IFS="${LIB_BASH_ORIGINAL_IFS}"

  # Push all outputs to result array.
  local _lbes_value
  for _lbes_value in "${_lbes_perl_array[@]}"; do
    if [[ "${_lbes_value: -1}" == $'\x1f' ]]; then
      _lbes_value="$(printf '%s' "${_lbes_value}" | escape_system)"
    else
      _lbes_value="$(printf "%s\x1f" "${_lbes_value}" | escape_system)"
    fi
    eval "${_lbes_array_out}+=(\"${_lbes_value%$'\x1f'}\")"
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

  get_option 'e:' _lbes_args[@] _lbes_options _lbes_params
  if [[ ${?} -ne 0 ]]; then
    error_code ${LIB_BASH_ERROR_INVALID_OPTION}
    return ${?}
  fi

  local _lbes_output=''
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

  local _lbes_escape_list="$(printf "%b\x1f" '"\$\\\\')"
  local _lbes_option=''
  for _lbes_option in "${_lbes_options[@]}"; do
    local _lbes_opt=''
    local _lbes_data=''

    parse_option "${_lbes_option}" _lbes_opt _lbes_data
    case "${_lbes_opt}" in
      e) _lbes_escape_list="$(printf "%b\x1f" "${_lbes_data}" | escape_perl_re)";;
    esac
  done

  if [[ "${_lbes_escape_list}" == $'\x1f' ]]; then
    eval "${_lbes_escaped_string}=\"\${_lbes_output}\""
    return 0
  fi

  _lbes_output="$(printf "%b\x1f" "${_lbes_output}" | \
                  perl -CS -pe 'use utf8; s/(['"${_lbes_escape_list%$'\x1f'}"'])/\\\1/g')"
  eval "${_lbes_escaped_string}=\"\${_lbes_output%\$'\x1f'}\""

  return 0
}

################################################################################
# Check whether the string match the given regular expression.
#
# Usage: match_string <string> <pattern> <modifier> <is_match_out>
#
# Parameters:
#   string       [in]  The string for checking.
#   pattern      [in]  The regular expression, it cannot be empty.
#   modifier     [in]  The regular expression modifier.
#   is_match_out [out] true if matched or else false.
#
# Returns:
#   ${LIB_BASH_ERROR_INVALID_PARAM}
#   ${LIB_BASH_ERROR_NO_OUTPUT}
#   ${LIB_BASH_INVALID_REGEX}
#
# This function will auto add '^' and '$' at the front and end of the pattern
# respectively.
#
# See http://perldoc.perl.org/perlre.html for more information.
################################################################################
function match_string()
{
  local _lbms_string="$(printf "%b\x1f" "${1}" | escape_perl)"
  local _lbms_pattern="${2}"
  local _lbms_modifier="${3}"
  local _lbms_is_match=${4}

  if [[ ${#} -lt 3 ]] || [[ -z "${_lbms_pattern}" ]]; then
    error_code ${LIB_BASH_ERROR_INVALID_PARAM}
    return ${?}
  fi

  if [[ -z "${_lbms_is_match}" ]]; then
    error_code ${LIB_BASH_ERROR_NO_OUTPUT}
    return ${?}
  fi

  # Append '^' at the start of pattern
  if [[ "${_lbms_pattern:0:1}" != '^' ]]; then
    _lbms_pattern="^${_lbms_pattern}"
  fi

  # Append '$' at the end of pattern
  if [[ "${_lbms_pattern: -1}" != '$' ]]; then
    _lbms_pattern="${_lbms_pattern}\$"
  fi

  _lbms_perl_out="$(perl -CS -e \
                    'use utf8;
                     "'"${_lbms_string%$'\x1f'}"'" =~
                       m/'"${_lbms_pattern}"'/'"${_lbms_modifier}"';
                     print $&' 2>/dev/null || exit ${?}; printf "\x1f")"
  if [[ ${?} -ne 0 ]]; then
    unset _lbms_perl_out
    error_code ${LIB_BASH_INVALID_REGEX}
    return ${?}
  fi
  if [[ -z "${_lbms_perl_out%$'\x1f'}" ]]; then
    eval "${_lbms_is_match}=false"
  else
    eval "${_lbms_is_match}=true"
  fi
  unset _lbms_perl_out

  return 0
}

################################################################################
# Find the matched pattern from string with the regular experession.
#
# Usage: regex_string <string> <pattern> <modifier> <match_out> <group_out>
#
# Parameters:
#   string    [in]  The string to find pattern.
#   pattern   [in]  The regular expression, it cannot be empty.
#   modifier  [in]  The regular expression modifier.
#   match_out [out] The matched string (*).
#   group_out [out] The array of captured group.
#
# Returns:
#   ${LIB_BASH_ERROR_INVALID_PARAM}
#   ${LIB_BASH_ERROR_NO_OUTPUT}
#   ${LIB_BASH_INTERNAL_ERROR}
#   ${LIB_BASH_INVALID_REGEX}
#
# * The string that matches the regular expression, if the modifier 'g' is used,
# the last matched string will be outputted.
#
# See http://perldoc.perl.org/perlre.html for more information.
################################################################################
function regex_string()
{
  local _lbrs_string="$(printf "%b\x1f" "${1}" | escape_perl)"
  local _lbrs_pattern="${2}"
  local _lbrs_modifier="${3}"
  local _lbrs_matched=${4}
  local _lbrs_group=${5}

  if [[ ${#} -lt 3 ]] || [[ -z "${_lbrs_pattern}" ]]; then
    error_code ${LIB_BASH_ERROR_INVALID_PARAM}
    return ${?}
  fi

  if [[ -z "${_lbrs_matched}" ]] || [[ -z "${_lbrs_group}" ]]; then
    error_code ${LIB_BASH_ERROR_NO_OUTPUT}
    return ${?}
  fi

  _lbrs_perl_out="$(perl -CS -e \
                    'use utf8;
                     @res =
                       "'"${_lbrs_string%$'\x1f'}"'"
                         =~ m/'"${_lbrs_pattern}"'/'"${_lbrs_modifier}"';
                     $\="\x1f";
                     print $&;
                     if ((scalar(@res) > 1) || ((scalar(@res) == 1) && ($1 & ~$1))) {
                       $,="\x1d";
                       print @res
                     } else {
                       print ""
                     }' 2>/dev/null)"
  if [[ ${?} -ne 0 ]]; then
    unset _lbrs_perl_out
    error_code ${LIB_BASH_INVALID_REGEX}
    return ${?}
  fi
  if [[ -z "${_lbrs_perl_out}" ]]; then
    unset _lbrs_perl_out
    eval "${_lbrs_matched}=''"
    eval "${_lbrs_group}=()"
    return 0
  fi

  # Extract matched string
  local _lbrs_matched_out=()
  explode_string "${_lbrs_perl_out%$'\x1f'}" $'\x1f' _lbrs_matched_out
  if [[ ${?} -ne 0 ]] || [[ ${#_lbrs_matched_out[@]} -ne 2 ]]; then
    unset _lbrs_perl_out
    error_code ${LIB_BASH_INTERNAL_ERROR}
    return ${?}
  fi
  unset _lbrs_perl_out

  # Extract capture groups
  local _lbrs_group_out=()
  if [[ -n "${_lbrs_matched_out[1]}" ]]; then
    explode_string "${_lbrs_matched_out[1]}" $'\x1d' _lbrs_group_out
    if [[ ${?} -ne 0 ]]; then
      error_code ${LIB_BASH_INTERNAL_ERROR}
      return ${?}
    fi
  fi

  # Reset outputs
  eval "${_lbrs_matched}=''"
  eval "${_lbrs_group}=()"

  # Matched string
  if [[ -n "${_lbrs_matched_out[0]}" ]]; then
    local _lbrs_matched_str="$(printf "%b\x1f" "${_lbrs_matched_out[0]}")"
    eval "${_lbrs_matched}=\"\${_lbrs_matched_str%\$'\x1f'}\""
  fi

  # Capture groups
  if [[ ${#_lbrs_group_out[@]} -gt 0 ]]; then
    local _lbrs_group_str=''
    for _lbrs_group_str in "${_lbrs_group_out[@]}"; do
      _lbrs_group_str="$(printf "%b\x1f" "${_lbrs_group_str}" | escape_system)"
      eval "${_lbrs_group}+=(\"${_lbrs_group_str%$'\x1f'}\")"
    done
  fi

  return 0
}

################################################################################
# Replace string with given regular expression.
#
# Usage: replace_string <string> <pattern> <subsitution> <modifier>
#                       <string_out>
#
# Parameters:
#   string      [in]  The string to replace.
#   pattern     [in]  The regular expression, it cannot be empty.
#   subsitution [in]  The replacing string.
#   modifier    [in]  The regular expression modifier.
#   string_out  [out] The replaced stirng.
#
# Returns:
#   ${LIB_BASH_ERROR_INVALID_PARAM}
#   ${LIB_BASH_ERROR_NO_OUTPUT}
#   ${LIB_BASH_INVALID_REGEX}
#
# See http://perldoc.perl.org/perlre.html for more information.
################################################################################
function replace_string()
{
  local _lbrs_string="$(printf "%b\x1f" "${1}" | escape_perl)"
  local _lbrs_pattern="${2}"
  local _lbrs_replace="${3}"
  local _lbrs_modifier="${4}"
  local _lbrs_replace_out=${5}

  if [[ ${#} -lt 4 ]] || [[ -z "${_lbrs_pattern}" ]]; then
    error_code ${LIB_BASH_ERROR_INVALID_PARAM}
    return ${?}
  fi

  if [[ -z "${_lbrs_replace_out}" ]]; then
    error_code ${LIB_BASH_ERROR_NO_OUTPUT}
    return ${?}
  fi

  _lbrs_perl_out="$(perl -CS -e \
                    'use utf8;
                     $_="'"${_lbrs_string%$'\x1f'}"'";
                     s/'"${_lbrs_pattern}"'/'"${_lbrs_replace}"'/'"${_lbrs_modifier}"';
                     $\="\x1f";
                     print $_;' 2>/dev/null)"
  if [[ ${?} -ne 0 ]]; then
    unset _lbrs_perl_out
    error_code ${LIB_BASH_INVALID_REGEX}
    return ${?}
  fi

  eval "${_lbrs_replace_out}=\"\${_lbrs_perl_out%\$'\x1f'}\""
  unset _lbrs_perl_out

  return 0
}
