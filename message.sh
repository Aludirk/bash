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
source 'string.sh'
popd &> /dev/null

export COLOR_BLACK=0
export COLOR_RED=1
export COLOR_GREEN=2
export COLOR_YELLOW=3
export COLOR_BLUE=4
export COLOR_MAGENTA=5
export COLOR_CYAN=6
export COLOR_WHITE=7

################################################################################
# Print message with color.
#
# Usage: message [-t] [-f color] [-b color] <message>
#
# Options:
#   -t       Bright text.
#   -f color Foreground color, use COLOR_*, default black.
#   -b color Background color, use COLOR_*, default no background.
#   -n       Do not print the trailing newline character.
#
# Parameters:
#   message [in] The message to print.
#
# Returns:
#   ${LIB_BASH_ERROR_INVALID_PARAM}
#   ${LIB_BASH_ERROR_INVALID_OPTION}
################################################################################
function message()
{
  local _lbm_args=("${@}")
  local _lbm_options=()
  local _lbm_params=()

  get_option 'tf:b:n' _lbm_args[@] _lbm_options _lbm_params
  if [[ ${?} -ne 0 ]]; then
    error_code ${LIB_BASH_ERROR_INVALID_OPTION}
    return ${?}
  fi

  if [[ ${#_lbm_params[@]} -lt 1 ]]; then
    error_code ${LIB_BASH_ERROR_INVALID_PARAM}
    return ${?}
  fi

  local _lbm_is_bright='0'
  local _lbm_foreground="3${COLOR_BLACK}"
  local _lbm_background=''
  local _lbm_newline="\n"
  local _lbm_option=''
  for _lbm_option in "${_lbm_options[@]}"; do
    local _lbm_opt=''
    local _lbm_data=''

    parse_option "${_lbm_option}" _lbm_opt _lbm_data
    case "${_lbm_opt}" in
      t) _lbm_is_bright='1';;
      f) _lbm_foreground="3${_lbm_data}";;
      b) _lbm_background="4${_lbm_data}";;
      n) _lbm_newline='';;
    esac
  done

  local _lbm_color=()

  # -t
  _lbm_color+=("${_lbm_is_bright}")

  # -f
  _lbm_color+=("${_lbm_foreground}")

  # -b
  if [[ -n "${_lbm_background}" ]]; then
    _lbm_color+=("${_lbm_background}")
  fi

  local _lbm_color_str=''
  implode_string _lbm_color[@] ';' _lbm_color_str

  printf "\e[${_lbm_color_str}m%b\e[0m${_lbm_newline}" "${_lbm_params[0]}"

  return 0
}

################################################################################
# Print information message.
#
# Usage: info <information>
#
# Parameters:
#   information [in] The information.
#
# Returns:
#   ${LIB_BASH_ERROR_INVALID_PARAM}
#
# The default color of the information message is green, and you can change it
# by setup ${LIB_BASH_INFO_COLOR}.
################################################################################
function info()
{
  local _lbi_info="${1}"

  if [[ ${#} -ne 1 ]]; then
    error_code ${LIB_BASH_ERROR_INVALID_PARAM}
    return ${?}
  fi

  message -t -f ${LIB_BASH_INFO_COLOR} "${_lbi_info}"
  if [[ ${?} -ne 0 ]]; then
    error_code ${LIB_BASH_ERROR_INVALID_PARAM}
    return ${?}
  fi
}

################################################################################
# Print error message.
#
# Usage: error <error>
#
# Parameters:
#   error [in] The error message.
#
# Returns:
#   ${LIB_BASH_ERROR_INVALID_PARAM}
#
# The default colors of the error message is white/red (FG/BG), and you can
# change it by setup ${LIB_BASH_ERROR_FG} and ${LIB_BASH_ERROR_BG}.
################################################################################
function error()
{
  local _lbe_error="${1}"

  if [[ ${#} -ne 1 ]]; then
    error_code ${LIB_BASH_ERROR_INVALID_PARAM}
    return ${?}
  fi

  message -t -f ${LIB_BASH_ERROR_FG} -b ${LIB_BASH_ERROR_BG} "${_lbe_error}" 1>&2
  if [[ ${?} -ne 0 ]]; then
    error_code ${LIB_BASH_ERROR_INVALID_PARAM}
    return ${?}
  fi
}

################################################################################
# Print question.
#
# Usage: question <question> <answer>
#
# Parameters:
#   question [in]  The question.
#   answer   [out] The answer.
#
# Returns:
#   ${LIB_BASH_ERROR_INVALID_PARAM}
#   ${LIB_BASH_ERROR_NO_OUTPUT}
#
# The default color of the questionis cyan, and you can change it by setup
# ${LIB_BASH_QUESTION_COLOR}.
################################################################################
function question()
{
  local _lbq_question="${1}"
  local _lbq_answer=${2}
  local _lbq_input=''

  if [[ ${#} -lt 1 ]]; then
    error_code ${LIB_BASH_ERROR_INVALID_PARAM}
    return ${?}
  fi

  message -t -f ${LIB_BASH_QUESTION_COLOR} -n "${_lbq_question}"
  if [[ ${?} -ne 0 ]]; then
    error_code ${LIB_BASH_ERROR_INVALID_PARAM}
    return ${?}
  fi
  read -r _lbq_input

  if [[ -z ${_lbq_answer} ]]; then
    error_code ${LIB_BASH_ERROR_NO_OUTPUT}
    return ${?}
  fi

  eval "${_lbq_answer}=\"\$(printf '%b' \"\${_lbq_input}\")\""
  return 0
}

################################################################################
# Ask to choose an option.
#
# Usage: select_option [-o|--option] <info> <options> <option_out>
#
# Options:
#   -o|--option Return the content of the selected option instead of index.
#
# Parameters:
#   info       [in]  The information to show before the option selection.
#   options    [in]  The array of options to select, it must at least contains
#                    two options.
#   option_out [out] The index of selected option, or the content of the
#                    selected option if -o|--option is specified.
#
# Returns:
#   ${LIB_BASH_ERROR_INVALID_PARAM}
#   ${LIB_BASH_ERROR_INVALID_OPTION}
#   ${LIB_BASH_ERROR_NO_OUTPUT}
#   ${LIB_BASH_INTERNAL_ERROR}
################################################################################
function select_option()
{
  local _lbso_args=("${@}")
  local _lbso_options=()
  local _lbso_params=()

  get_option 'o[option]' _lbso_args[@] _lbso_options _lbso_params
  if [[ ${?} -ne 0 ]]; then
    error_code ${LIB_BASH_ERROR_INVALID_OPTION}
    return ${?}
  fi

  local _lbso_output_index=true
  local _lbso_option=''
  for _lbso_option in "${_lbso_options[@]}"; do
    local _lbso_opt=''
    local _lbso_data=''

    parse_option "${_lbso_option}" _lbso_opt _lbso_data
    case "${_lbso_opt}" in
      o) _lbso_output_index=false;;
    esac
  done

  local _lbso_info=''
  local _lbso_option_arr=()
  if [[ ${#_lbso_params[@]} -lt 2 ]]; then
    error_code ${LIB_BASH_ERROR_INVALID_PARAM}
    return ${?}
  else
    _lbso_info="${_lbso_params[0]}"
    eval "_lbso_option_arr=(\"\${${_lbso_params[1]}}\")"

    if [[ ${#_lbso_option_arr[@]} -lt 2 ]]; then
      error_code ${LIB_BASH_ERROR_INVALID_PARAM}
      return ${?}
    fi
  fi

  local _lbso_option_out
  if [[ ${#_lbso_params[@]} -lt 3 ]] || [[ -z "${_lbso_params[2]}" ]]; then
    error_code ${LIB_BASH_ERROR_NO_OUTPUT}
    return ${?}
  else
    _lbso_option_out=${_lbso_params[2]}
  fi

  # Show the message for asking options.
  if [[ -n "${_lbso_info}" ]]; then
    info "${_lbso_info}"
    if [[ ${?} -ne 0 ]]; then
      error_code ${LIB_BASH_INTERNAL_ERROR}
      return ${?}
    fi
  fi

  # Show the options.
  local _lbso_index=0
  local _lbso_option_max="${#_lbso_option_arr[@]}"
  local _lbso_option_str_len="${#_lbso_option_max}"
  for _lbso_index in "${!_lbso_option_arr[@]}"; do
    printf \
      "  %*s) %b\n" \
      ${_lbso_option_str_len} "$[_lbso_index + 1]" "${_lbso_option_arr[${_lbso_index}]}"
  done
  printf "\n"

  # Construct the prompt.
  local _lbso_prompt="$(printf '1-%d ? ' ${#_lbso_option_arr[@]})"

  # Read the option selected.
  local _lbso_option_read
  until  [[ -n "${_lbso_option_read}" ]]; do
    local _lbso_input=''

    question "\e[1A\e[2K${_lbso_prompt}" _lbso_input
    if [[ ${?} -ne 0 ]]; then
      error_code ${LIB_BASH_INTERNAL_ERROR}
      return ${?}
    fi

    local is_number=false
    match_string "${_lbso_input}" '\d+' '' is_number
    if [[ ${is_number} == true ]] \
    && [[ ${_lbso_input} -ge 1 ]] \
    && [[ ${_lbso_input} -le ${#_lbso_option_arr[@]} ]]; then
      _lbso_option_read=$[_lbso_input - 1]
    fi
  done

  if [[ ${_lbso_output_index} == true ]]; then
    eval "${_lbso_option_out}=${_lbso_option_read}"
  else
    _lbso_option_read="$(printf '%b\x1f' "${_lbso_option_arr[${_lbso_option_read}]}" | \
      escape_system)"
    eval "${_lbso_option_out}=\"${_lbso_option_read%$'\x1f'}\""
  fi

  return 0
}
