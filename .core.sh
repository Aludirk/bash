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

# Version
LIB_BASH_VERSION=0.5.0

# Save the IFS.
LIB_BASH_ORIGINAL_IFS="${IFS}"

################################################################################
# Set up the default library configuration.
################################################################################

# Whether the bash library in debug mode which will output the error message to
# stderr.
LIB_BASH_DEBUG=${LIB_BASH_DEBUG:-false}

# The foreground color of error message, default is white.
LIB_BASH_ERROR_FG=${LIB_BASH_ERROR_FG:-7}

# The background color of error message, default is red.
LIB_BASH_ERROR_BG=${LIB_BASH_ERROR_BG:-1}

# The color of information message, default is green.
LIB_BASH_INFO_COLOR=${LIB_BASH_INFO_COLOR:-2}

# The color of question message, default is cyan.
LIB_BASH_QUESTION_COLOR=${LIB_BASH_QUESTION_COLOR:-6}

################################################################################
# Error codes.
################################################################################

# Invalid parameters.
LIB_BASH_ERROR_INVALID_PARAM=3

# Invalid options.
LIB_BASH_ERROR_INVALID_OPTION=4

# No outputs.
LIB_BASH_ERROR_NO_OUTPUT=5

# File does not exist.
LIB_BASH_ERROR_FILE_NOT_EXIST=6

################################################################################
# Show the error message in 'stderr' for the given error code in DEBUG mode.
#
# Usage: error_code_func <file_name> <line_no> <error_code>
#
# Parameters:
#   file_name  [in] The name of file to trigger the error.
#   line_no    [in] The line no of the location of the error.
#   error_code [in] The error code, define in `LIB_BASH_ERROR_*`.
#
# Returns:
#   Same as `${error_code}`.
################################################################################
function error_code_func()
{
  local _lbecf_file_name="${1}"
  local _lbecf_line_no=${2}
  local _lbecf_error_code=${3}

  if [[ ${_lbecf_error_code} -eq 0 ]]; then
    return 0
  fi

  if ${LIB_BASH_DEBUG}; then
    local _lbecf_err_msg=""

    case ${_lbecf_error_code} in
      3) _lbecf_err_msg="Invalid parameters.";;
      4) _lbecf_err_msg="Invalid options.";;
      5) _lbecf_err_msg="No outputs.";;
      6) _lbecf_err_msg="File does not exist.";;
      *) return ${_lbecf_error_code};;
    esac

    _lbecf_err_msg="${_lbecf_err_msg} (${_lbecf_file_name}:${_lbecf_line_no})"
    printf "%s\n" "\e[1;3${LIB_BASH_ERROR_FG};4${LIB_BASH_ERROR_BG}m${_lbecf_err_msg}\e[0m" 1>&2
  fi

  return ${_lbecf_error_code}
}

################################################################################
# Library aliases
################################################################################
shopt -s expand_aliases

# Set alias 'error_code' for handy use of 'error_code_func'
alias error_code='error_code_func "${BASH_SOURCE[0]}" ${LINENO}'

# Set alias 'esacpe_system' for esacping the system characters '"\$'
alias escape_system="sed 's/\\([\"\\\$]\\)/\\\\\\1/g'"
