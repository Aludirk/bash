################################################################################
# MIT License
#
# Copyright (c) 2016 Aludirk Wong <aludirkwong@gmail.com>
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
popd &> /dev/null

################################################################################
# Simulate the function `getopt`.
#
# Usage: get_option <option_string> <args> <option_out> <param_out>
#
# Parameters:
#   option_string [in]  Option string (*).
#   args          [in]  The array of arguments.
#   option_out    [out] The array of parsed options, the result can use
#                       `parse_option` to parse.
#   param_out     [out] The array of parsed parameters.
#
# Returns:
#   ${LIB_BASH_ERROR_INVALID_PARAM}
#   ${LIB_BASH_ERROR_INVALID_OPTION}
#   ${LIB_BASH_ERROR_NO_OUTPUT}
#
# `get_option` supports '--' for indicate the end of options and long option,
# besides all whitespace inside the options and parameters are preserved.
#
# *:
# The option string is a list of option configuration with pattern `o[option]:`
#   o        The short option, this is a required field and must be an alphabet.
#   [option] The long option, this is optional and must be alphabets and '_'.
#   :        The colon indicate the option will have data to follow.
# Example:
#   ab[beta]c:d[delta]:
#   This option string indicate 4 possible options:
#     1st option - short:a long: data:no
#     2nd option - short:b long:beta data:no
#     3rd option - short:c long: data:yes
#     4th option - short:d long:delta data:yes
################################################################################
function get_option()
{
  local _lbgo_opt_pattern='[a-zA-Z](?:\[[a-zA-Z][a-zA-Z_]+\])?:?'
  local _lbgo_opt_capture='([a-zA-Z])(?:\[([a-zA-Z][a-zA-Z_]+)\])?(:)?'

  local _lbgo_option_string="$(printf '%s' "${1}" | escape_perl)"
  local _lbgo_args=("${!2}")
  local _lbgo_option_out=${3}
  local _lbgo_param_out=${4}

  if [[ ${#} -lt 2 ]] || [[ -z "${_lbgo_option_string}" ]]; then
    error_code ${LIB_BASH_ERROR_INVALID_PARAM}
    return ${?}
  fi

  if [[ -z "${_lbgo_option_out}" ]] || [[ -z "${_lbgo_param_out}" ]]; then
    error_code ${LIB_BASH_ERROR_NO_OUTPUT}
    return ${?}
  fi

  # Validate the option string.
  local _lbgo_match="$(perl -e \
                       '"'"${_lbgo_option_string}"'" =~ m/^(?:'${_lbgo_opt_pattern}')+$/;
                        print $&')"
  if [[ "${_lbgo_match}" != "${_lbgo_option_string}" ]]; then
    error_code ${LIB_BASH_ERROR_INVALID_PARAM}
    return ${?}
  fi

  # Reset the outputs.
  eval "${_lbgo_option_out}=()"
  eval "${_lbgo_param_out}=()"

  # Split the option string.
  local _lbgo_option_strings="$(perl -e \
                                '@res = "'"${_lbgo_option_string}"'" =~ m/'${_lbgo_opt_pattern}'/g;
                                 $,="\x1e";
                                 print @res')"
  IFS=$'\x1e'
  local _lbgo_option_strings=(${_lbgo_option_strings})
  IFS="${LIB_BASH_ORIGINAL_IFS}"
  local _lbgo_option_count=${#_lbgo_option_strings[@]}

  # Parse the option string.
  local _lbgo_index=1
  local _lbgo_option=''
  for _lbgo_option in "${_lbgo_option_strings[@]}"; do
    _lbgo_option="$(printf '%s' "${_lbgo_option}" | escape_perl)"
    local _lbgo_option_seg="$(perl -e '@res = "'"${_lbgo_option}"'" =~ m/'${_lbgo_opt_capture}'/;
                                       $,="\x1e";
                                       print @res')"
    IFS=$'\x1e'
    eval "local _lbgo_option${_lbgo_index}=(\${_lbgo_option_seg})"
    IFS="${LIB_BASH_ORIGINAL_IFS}"
    ((++_lbgo_index))
  done

  # Parse the arguments.
  while [[ ${#_lbgo_args[@]} -gt 0 ]]; do
    local _lbgo_shift_count=0
    local _lbgo_option=''
    local _lbgo_data=''

    # Handle '--'.
    if [[ "${_lbgo_args[0]}" == '--' ]]; then
      _lbgo_args=("${_lbgo_args[@]:1}")
      break
    fi

    # Escape the argument.
    local _lbgo_arg="$(printf '%s' "${_lbgo_args[0]}" | escape_perl)"

    local _lbgo_index=0
    for _lbgo_index in $(seq 1 ${_lbgo_option_count}); do
      eval "local _lbgo_short=\${_lbgo_option${_lbgo_index}[0]}"
      eval "local _lbgo_long=\${_lbgo_option${_lbgo_index}[1]}"
      eval "local _lbgo_have_data=\${_lbgo_option${_lbgo_index}[2]}"

      if [[ -z "${_lbgo_have_data}" ]]; then
        # Without data.
        if [[ "${_lbgo_arg}" == "-${_lbgo_short}" ]]; then
          # Pattern: -o
          _lbgo_shift_count=1
          _lbgo_option="${_lbgo_short}"
          break
        elif [[ -n "${_lbgo_long}" ]] && [[ "${_lbgo_arg}" == "--${_lbgo_long}" ]]; then
          # Pattern: --option
          _lbgo_shift_count=1
          _lbgo_option="${_lbgo_short}"
          break
        fi
      else
        # With data.
        if [[ "${_lbgo_arg}" == "-${_lbgo_short}" ]]; then
          # Pattern: -o data
          _lbgo_shift_count=2
          _lbgo_option="${_lbgo_short}"
          _lbgo_data="${_lbgo_args[1]}"
          break
        else
          # Pattern: -odata
          local _lbgo_match="$(perl -e \
                               '"'"${_lbgo_arg}"'" =~ m/^-'"${_lbgo_short}"'.+$/; print $&')"
          if [[ -n "${_lbgo_match}" ]]; then
            _lbgo_shift_count=1
            _lbgo_option="${_lbgo_short}"
            _lbgo_data="$(perl -e \
                          '@res = "'"${_lbgo_arg}"'" =~ m/-'"${_lbgo_short}"'(.+)/; print @res')"
            break
          fi

          # Pattern: --option=data
          if [[ -n "${_lbgo_long}" ]]; then
            local _lbgo_match="$(perl -e \
                                 '"'"${_lbgo_arg}"'" =~ m/^--'"${_lbgo_long}"'=.*/; print $&')"
            if [[ -n "${_lbgo_match}" ]]; then
              _lbgo_shift_count=1
              _lbgo_option="${_lbgo_short}"
              _lbgo_data="$(perl -e \
                            '@res = "'"${_lbgo_arg}"'" =~ m/--'"${_lbgo_long}"'=(.*)/; print @res')"
              break
            fi
          fi
        fi
      fi
    done

    if [[ ${_lbgo_shift_count} -eq 0 ]]; then
      if [[ -z "${_lbgo_arg}" ]]; then
        break
      fi

      # Check invalid option.
      local _lbgo_match_short="$(perl -e '"'"${_lbgo_arg}"'" =~ m/^-[a-zA-Z]$/; print $&')"
      local _lbgo_match_long="$(perl -e \
                                '"'"${_lbgo_arg}"'" =~ m/^--[a-zA-Z][a-zA-Z_]+.*$/; print $&')"
      if [[ "${_lbgo_arg}" != "${_lbgo_match_short}" ]] \
      && [[ "${_lbgo_arg}" != "${_lbgo_match_long}" ]]; then
        break
      fi

      error_code ${LIB_BASH_ERROR_INVALID_OPTION}
      return ${?}
    else
      # Pop the processed arguments.
      _lbgo_args=("${_lbgo_args[@]:${_lbgo_shift_count}}")

      # Add option.
      _lbgo_data="$(printf "%b\x1f" "${_lbgo_data}" | escape_system)"
      eval "${_lbgo_option_out}+=(\"${_lbgo_option}:${_lbgo_data%$'\x1f'}\")"
    fi
  done

  # Store the parameters.
  local _lbgo_param=''
  for _lbgo_param in "${_lbgo_args[@]}"; do
    _lbgo_param="$(printf "%b\x1f" "${_lbgo_param}" | escape_system)"
    eval "${_lbgo_param_out}+=(\"${_lbgo_param%$'\x1f'}\")"
  done

  return 0
}

################################################################################
# Parse the option output from `get_option`.
#
# Usage: parse_option <option_result> <option_out> <data_out>
#
# Parameters:
#   option_result [in]  The option output from `get_option`
#   option_out    [out] The short option as key.
#   data_out      [out] The data from the argument.
#
# Returns:
#   ${LIB_BASH_ERROR_INVALID_PARAM}
#   ${LIB_BASH_ERROR_NO_OUTPUT}
################################################################################
function parse_option()
{
  local _lbpo_option_result="${1}"
  local _lbpo_option_out=${2}
  local _lbpo_data_out=${3}

  if [[ -z "${_lbpo_option_result}" ]]; then
    error_code ${LIB_BASH_ERROR_INVALID_PARAM}
    return ${?}
  fi

  if [[ -z "${_lbpo_option_out}" ]] || [[ -z "${_lbpo_data_out}" ]]; then
    error_code ${LIB_BASH_ERROR_NO_OUTPUT}
    return ${?}
  fi

  printf -v ${_lbpo_option_out} "%b\x1f" "${_lbpo_option_result:0:1}"
  eval "${_lbpo_option_out}=\"\${${_lbpo_option_out}%\$'\x1f'}\""
  printf -v ${_lbpo_data_out} "%b\x1f" "${_lbpo_option_result:2}"
  eval "${_lbpo_data_out}=\"\${${_lbpo_data_out}%\$'\x1f'}\""

  return 0
}
