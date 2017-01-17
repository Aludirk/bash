# Module - String

String manipulation.

* [implode_string](#implode_string)
* [explode_string](#explode_string)
* [escape_string](#escape_string)
* [match_string](#match_string)
* [regex_string](#regex_string)
* [replace_string](#replace_string)

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
array=('Hello' 'World' '!!!')
implode_string array[@] ' ' result

printf "%s\n" "${result}"
###
# Hello World !!!
###
```

```bash
array=('1st line' '2nd line' '3rd line')
implode_string array[@] $'\n' result

printf "%s\n" "${result}"
###
# 1st line
# 2nd line
# 3rd line
###
```

```bash
array=('one' 'two' 'three')
implode_string array[@] ' and ' result

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
explode_string 'Hello World !!!' ' ' result

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
explode_string 'ABC,DEF GHI|JKL' ', |' result

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
escape_string -e '&,' 'ABC"D,F\G&I$JKL' result

printf "%s\n" "${result}"
###
# ABC"D\,F\G\&I$JKL
###
```

## match_string

```
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
```

Examples:
```bash
match_string 'example@email.com' '[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+' '' is_match

if [[ ${is_match} == true ]]; then
  printf "This is an email.\n"
else
  printf "This is not an email.\n"
fi
###
# This is an email.
###
```

```bash
match_string "LINE1\nLINE2\nLINE3" 'LINE.+3' 's' is_match

if [[ ${is_match} == true ]]; then
  printf "Matched\n"
else
  printf "Not matched\n"
fi
###
# Matched
###
```

## regex_string

```
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
```

Examples:
```bash
regex_string 'AB CD' '(?<=\w)(\W*?)(?=\w)' 'g' matched group

printf "Matched: \"%s\"\n" "${matched}"
for key in "${!group[@]}"; do
  printf "Group ${key}: \"%s\"\n" "${group[${key}]}"
done
###
# Matched: ""
# Group 0: ""
# Group 1: " "
# Group 2: ""
###
```

```bash
regex_string \
  "1. test@example.com\n2. test.test@example.com\n3. test_test@example.com.hk" \
  '[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+' \
  'gm' \
  matched \
  group

printf "Matched: \"%s\"\n" "${matched}"
for key in "${!group[@]}"; do
  printf "Group ${key}: \"%s\"\n" "${group[${key}]}"
done
###
# Matched: "test_test@example.com.hk"
# Group 0: "test@example.com"
# Group 1: "test.test@example.com"
# Group 2: "test_test@example.com.hk"
###
```

```bash
regex_string "abc=abc\nabc=def\ndef=abc\ndef=def" '((abc|def)=\2)' 'gm' matched group

printf "Matched: \"%s\"\n" "${matched}"
for key in "${!group[@]}"; do
  printf "Group ${key}: \"%s\"\n" "${group[${key}]}"
done

###
# Matched: "def=def"
# Group 0: "abc=abc"
# Group 1: "abc"
# Group 2: "def=def"
# Group 3: "def"
###
```

## replace_string

```
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
```
Examples:
```bash
replace_string 'Hello World !!!' 'H\w+' 'Good Night' '' replaced

printf "${replaced}\n"
###
# Good Night World !!!
###
```

```bash
# template.conf
host=<HOST>
database=<HOST>
password=<PASSWORD>


# make_config.sh
CONFIG="$(cat 'template.conf'; printf $'\x1f')"
replace_string "${CONFIG%$'\x1f'}" '<HOST>' '127.0.0.1' 'g' new_config
replace_string "${new_config}" '<PASSWORD>' '123456' 'g' new_config
printf "${new_config}" > config.conf

cat config.conf
###
# host=127.0.0.1
# database=127.0.0.1
# password=123456
#
###
```
