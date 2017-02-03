# Module - Dictionary

As there is lack of dictionary in Bash 3.x, this implementation mimics a dictionary and providing basic operations such as `get`, `set`, `unset`, etc.

* [dict_init](#dict_init)
* [dict_destroy](#dict_destroy)
* [dict_get](#dict_get)
* [dict_set](#dict_set)
* [dict_unset](#dict_unset)
* [dict_clear](#dict_clear)
* [dict_count](#dict_count)
* [dict_keys](#dict_keys)
* [dict_values](#dict_values)

## dict_init

```
################################################################################
# Initialize dictionary.
#
# Usage: dict_init <dict_out>
#
# Parmeters:
#   dict_out [out] The initialized dictionary, should use `dict_destroy` to
#                  destroy.
#
# Returns:
#   ${LIB_BASH_ERROR_NO_OUTPUT}
################################################################################
```

Example:
```bash
dict_init dict
dict_destroy "${dict}"
```

## dict_destroy

```
################################################################################
# Destroy dictionary.
#
# Usage: dict_destroy <dict>
#
# Parameters:
#   dict [in] The dictionary to destroy.
#
# Returns:
#   ${LIB_BASH_ERROR_INVALID_PARAM}
################################################################################
```

Please see the example from [dict_init](#dict_init).

## dict_get

```
################################################################################
# Retrieve the value from the dictionary.
#
# Usage: dict_get <dict> <key> <value_out>
#
# Parameters:
#   dict      [in]  The dictionary for operation.
#   key       [in] The key for the value to get.
#   value_out [out] The value.
#
# Returns:
#   ${LIB_BASH_ERROR_INVALID_PARAM}
#   ${LIB_BASH_ERROR_NO_OUTPUT}
################################################################################
```

Example:
```bash
dict_init dict
dict_set "${dict}" 'key' 1
dict_get "${dict}" 'key' value
dict_destroy "${dict}"

printf "${value}\n"
###
# 1
###
```

## dict_set

```
################################################################################
# Set the value for the dictionary.
#
# Usage: dict_set <dict> <key> <value>
#
# Parameters:
#   dict  [in] The dictionary for operation.
#   key   [in] The key for the value to set, it must be alphabet or digit or
#              underscore.
#   value [in] The new value.
#
# Returns:
#   ${LIB_BASH_ERROR_INVALID_PARAM}
################################################################################
```

Please see the example from [dict_get](#dict_get).

## dict_unset

```
################################################################################
# Unset the value from the dictionary.
#
# Usage: dict_unset <dict> <key>
#
# Parameters:
#   dict [in] The dictionary for operation.
#   key  [in] The key for the value to unset.
#
# Returns:
#   ${LIB_BASH_ERROR_INVALID_PARAM}
################################################################################
```

Example:
```bash
dict_init dict
dict_set "${dict}" 'key' 1
dict_get "${dict}" 'key' ori_value
dict_unset "${dict}" 'key'
dict_get "${dict}" 'key' new_value
dict_destroy "${dict}"

printf "Before unset: ${ori_value}\n"
printf "After unset: ${new_value}\n"
###
# Before unset: 1
# After unset:
#
```

## dict_clear

```
################################################################################
# Clear all elements in dictionary.
#
# Usage: dict_clear <dict>
#
# Parameters:
#   dict [in] The dictionary for operation.
#
# Returns:
#   ${LIB_BASH_ERROR_INVALID_PARAM}
#   ${LIB_BASH_INTERNAL_ERROR}
################################################################################
```

Example:
```bash
dict_init dict
dict_set "${dict}" 'key1' 1
dict_set "${dict}" 'key2' 2
dict_set "${dict}" 'key3' 3
dict_count "${dict}" ori_count
dict_clear "${dict}"
dict_count "${dict}" new_count
dict_destroy "${dict}"

printf "Before clear: ${ori_count}\n"
printf "After clear: ${new_count}\n"
###
# Before clear: 3
# After clear: 0
###
```

## dict_count

```
################################################################################
# Retrieve the number of element of the dictionary.
#
# Usage: dict_count <dict> <count_out>
#
# Parameters:
#   dict      [in]  The dictionary for operation.
#   count_out [out] The number of element.
#
# Returns:
#   ${LIB_BASH_ERROR_INVALID_PARAM}
#   ${LIB_BASH_ERROR_NO_OUTPUT}
################################################################################
```

```bash
dict_init dict
dict_set "${dict}" 'key1' 1
dict_set "${dict}" 'key2' 2
dict_set "${dict}" 'key3' 3
dict_count "${dict}" count
dict_destroy "${dict}"

printf "Count: ${count}\n"
###
# Count: 3
###
```

## dict_keys

```
################################################################################
# Retrieve the array of the keys in dictionary.
#
# Usage: dict_keys <dict> <keys_out>
#
# Parameters:
#   dict     [in]  The dictionary for operation.
#   keys_out [out] The array of the keys.
#
# Returns:
#   ${LIB_BASH_ERROR_INVALID_PARAM}
#   ${LIB_BASH_ERROR_NO_OUTPUT}
################################################################################
```

Example:
```bash
dict_init dict
dict_set "${dict}" 'key1' 1
dict_set "${dict}" 'key2' 2
dict_set "${dict}" 'key3' 3
dict_keys "${dict}" keys
dict_destroy "${dict}"

for index in "${!keys[@]}"; do
  printf "Key at %d: %s\n" ${index} "${keys[${index}]}"
done
###
# Key at 0: key1
# Key at 1: key2
# Key at 2: key3
###
```

## dict_values

```
################################################################################
# Retrieve the array of the values in dictionary.
#
# Usage: dict_values <dict> <values_out>
#
# Parameters:
#   dict       [in]  The dictionary for operation.
#   values_out [out] The array of the values.
#
# Returns:
#   ${LIB_BASH_ERROR_INVALID_PARAM}
#   ${LIB_BASH_ERROR_NO_OUTPUT}
#   ${LIB_BASH_INTERNAL_ERROR}
################################################################################
```

Example:
```bash
dict_init dict
dict_set "${dict}" 'key1' 1
dict_set "${dict}" 'key2' 2
dict_set "${dict}" 'key3' 3
dict_values "${dict}" values
dict_destroy "${dict}"

for index in "${!values[@]}"; do
  printf "Value at %d: %s\n" ${index} "${values[${index}]}"
done
###
# Value at 0: 1
# Value at 1: 2
# Value at 2: 3
###
```
