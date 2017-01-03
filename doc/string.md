# Module - String

String manipulation.

* [implode_string](#implode_string)
* [explode_string](#explode_string)

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
