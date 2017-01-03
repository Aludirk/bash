# Module - String

String manipulation.

* [implode_string](#implode_string)
* [explode_string](#explode_string)
* [escape_string](#escape_string)

## implode_string

```
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
```

Examples:
```bash
array=("Hello" "World" "!!!")
implode_string array[@] " " result

printf "%s\n" "${result}"
###
# Hello World !!!
###
```

```bash
array=("1st line" "2nd line" "3rd line")
implode_string array[@] $'\n' result

printf "%s\n" "${result}"
###
# 1st line
# 2nd line
# 3rd line
###
```

```bash
array=("one" "two" "three")
implode_string array[@] " and " result

printf "%s\n" "${result}"
###
# one and two and three
###
```

## explode_string

```
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
```

Examples:
```bash
explode_string "Hello World !!!" " " result

printf "%s\n" "${result[0]}"
printf "%s\n" "${result[1]}"
printf "%s\n" "${result[2]}"
###
# Hello
# World
# !!!
###
```

```bash
explode_string "ABC,DEF GHI|JKL" ", |" result

printf "%s\n" "${result[0]}"
printf "%s\n" "${result[1]}"
printf "%s\n" "${result[2]}"
printf "%s\n" "${result[3]}"
###
# ABC
# DEF
# GHI
# JKL
###
```

## escape_string

```
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
```

Examples:
```bash
escape_string 'ABC"DEF\GHI$JKL' result

printf "%s\n" "${result}"
###
# ABC\"DEF\\GHI\$JKL
###
```

```bash
escape_string -e "&," 'ABC"D,F\G&I$JKL' result

printf "%s\n" "${result}"
###
# ABC"D\,F\G\&I$JKL
###
```
