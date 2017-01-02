# Module - Command

Command/Function utility.

* [get_option](#get_option)
* [parse_option](#parse_option)

## get_option

```
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
```

Example 1:
```bash
################################################################################
# argument.sh

#!/usr/bin/env bash

source "command.sh"

args=("${@}")
get_option "ab[beta]c:d[delta]:e:" args[@] options params
exit_code=${?}
if [[ ${exit_code} -ne 0 ]]; then
  exit ${exit_code}
fi

for option in "${options[@]}"; do
  parse_option "${option}" opt data
  printf "Option:${opt} Data:${data}\n"
done

for param in "${params[@]}"; do
  printf "Param:${param}\n"
done
```
Output:
```bash
$ ./argument.sh -a -beta -c ccc --delta=ddd -eee p1 p2
Option:a Data:
Option:b Data:
Option:c Data:ccc
Option:d Data:ddd
Option:e Data:eee
Param:p1
Param:p2
```

Example 2:
```bash
function argument()
{
  local args=("${@}")

  local options=()
  local params=()
  get_option "ab[beta]c:d[delta]:e:" args[@] options params
  exit_code=${?}
  if [[ ${exit_code} -ne 0 ]]; then
    return ${exit_code}
  fi

  local option=""
  for option in "${options[@]}"; do
    local opt=""
    local data=""
    parse_option "${option}" opt data
    printf "Option:${opt} Data:${data}\n"
  done

  local param=""
  for param in "${params[@]}"; do
    printf "Param:${param}\n"
  done

  return 0
}

argument -a --beta -c ccc --delta=ddd -eeee p1 p2
```
Output:
```bash
Option:a Data:
Option:b Data:
Option:c Data:ccc
Option:d Data:ddd
Option:e Data:eee
Param:p1
Param:p2
```

## parse_option

```
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
```

Please see the example from [get_option](#get_option).
