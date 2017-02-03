load "${BATS_TEST_DIRNAME}/../bats-support/load.bash"
load "${BATS_TEST_DIRNAME}/../bats-assert/load.bash"

source "${BATS_TEST_DIRNAME}/../../dictionary.sh"

@test '_dict_check_key - normal' {
  local result=false

  _dict_check_key 'KEY' result
  assert_equal ${result} true
}

@test '_dict_check_key - underscore' {
  local result=false

  _dict_check_key 'KEY_1' result
  assert_equal ${result} true
}

@test '_dict_check_key - invalid key pattern' {
  local result=true

  _dict_check_key 'A*C' result
  assert_equal ${result} false
}

@test '_dict_check_key - success' {
  local result=false

  run _dict_check_key 'KEY' result
  assert_success
  assert_output ''
}

@test '_dict_check_key - invalid parameters' {
  run _dict_check_key
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}
}

@test '_dict_check_key - no outputs' {
  run _dict_check_key 'KEY'
  assert_failure ${LIB_BASH_ERROR_NO_OUTPUT}
}

@test 'dict_init - normal' {
  local dict
  local result=false

  dict_init dict
  if [[ "${!dict+x}" ]]; then
    result=true
  fi
  assert_equal ${result} true

  dict_destroy "${dict}"
}

@test 'dict_init - success' {
  local dict

  run dict_init dict
  assert_success
  assert_output ''

  dict_destroy "${dict}"
}

@test 'dict_init - no outputs' {
  run dict_init
  assert_failure ${LIB_BASH_ERROR_NO_OUTPUT}
}

@test 'dict_destroy - normal' {
  local dict
  local result=false

  dict_init dict
  dict_set "${dict}" 'key1' 1
  dict_set "${dict}" 'key2' 2

  if [[ ${!dict+x} ]]; then
    result=true
  fi
  assert_equal ${result} true

  local key1="${dict}__key1"
  result=false
  if [[ ${!key1+x} ]]; then
    result=true
  fi
  assert_equal ${result} true

  local key2="${dict}__key2"
  result=false
  if [[ ${!key2+x} ]]; then
    result=true
  fi
  assert_equal ${result} true

  dict_destroy "${dict}"
  result=false
  if [[ ! ${!dict+x} ]]; then
    result=true
  fi
  assert_equal ${result} true

  local key1="${dict}__key1"
  result=false
  if [[ ! ${!key1+x} ]]; then
    result=true
  fi
  assert_equal ${result} true

  local key2="${dict}__key2"
  result=false
  if [[ ! ${!key2+x} ]]; then
    result=true
  fi
  assert_equal ${result} true
}

@test 'dict_destroy - success' {
  local dict

  dict_init dict
  run dict_destroy "${dict}"
  assert_success
  assert_output ''
}

@test 'dict_destroy - invalid parameters' {
  run dict_destroy
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}
}

@test 'dict_get/dict_set - normal' {
  local dict
  local value

  dict_init dict
  dict_set "${dict}" 'key' 1
  dict_get "${dict}" 'key' value
  assert_equal "${value}" 1

  dict_destroy "${dict}"
}

@test 'dict_get/dict_set - special characters' {
  local dict
  local value
  local expect

  dict_init dict
  dict_set "${dict}" '1' '"'
  dict_set "${dict}" '2' '\'
  dict_set "${dict}" '3' '$'
  dict_set "${dict}" '4' '@'
  dict_set "${dict}" '5' "x\nx"
  dict_set "${dict}" '6' "\n"

  dict_get "${dict}" '1' value
  assert_equal "${value}" '"'

  dict_get "${dict}" '2' value
  assert_equal "${value}" '\'

  dict_get "${dict}" '3' value
  assert_equal "${value}" '$'

  dict_get "${dict}" '4' value
  assert_equal "${value}" '@'

  dict_get "${dict}" '5' value
  assert_equal "${value}" "$(printf "x\nx")"

  dict_get "${dict}" '6' value
  printf -v expect "\n"
  assert_equal "${value}" "${expect}"

  dict_destroy "${dict}"
}

@test 'dict_get/dict_set - empty string' {
  local dict
  local value

  dict_init dict
  dict_set "${dict}" 'key' ''
  dict_get "${dict}" 'key' value
  assert_equal "${value}" ''

  dict_destroy "${dict}"
}

@test 'dict_get/dict_set - UTF-8' {
  local dict
  local value

  dict_init dict
  dict_set "${dict}" '1' '一'
  dict_set "${dict}" '2' '二'
  dict_set "${dict}" '3' '三'

  dict_get "${dict}" '1' value
  assert_equal "${value}" '一'

  dict_get "${dict}" '2' value
  assert_equal "${value}" '二'

  dict_get "${dict}" '3' value
  assert_equal "${value}" '三'

  dict_destroy "${dict}"
}

@test 'dict_get/dict_set - double underscores' {
  local dict
  local value

  dict_init dict
  dict_set "${dict}" '__key__' 1
  dict_get "${dict}" '__key__' value
  assert_equal "${value}" 1

  dict_destroy "${dict}"
}

@test 'dict_get/dict_set reset key' {
  local dict
  local value

  dict_init dict

  dict_set "${dict}" 'key' 1
  dict_get "${dict}" 'key' value
  assert_equal "${value}" 1

  dict_set "${dict}" 'key' 2
  dict_get "${dict}" 'key' value
  assert_equal "${value}" 2

  dict_destroy "${dict}"
}

@test 'dict_get - key not found' {
  local dict
  local value='xxx'

  dict_init dict
  dict_get "${dict}" 'key' value
  assert_equal "${value}" ''

  dict_destroy "${dict}"
}

@test 'dict_get - invalid key' {
  local dict
  local value='xxx'

  dict_init dict
  dict_get "${dict}" '###' value
  assert_equal "${value}" ''

  dict_destroy "${dict}"
}

@test 'dict_get - success' {
  local dict
  local value

  dict_init dict
  dict_set "${dict}" 'key' 1
  run dict_get "${dict}" 'key' value
  assert_success
  assert_output ''

  dict_destroy "${dict}"
}

@test 'dict_get - invalid parameters' {
  local dict
  local value

  run dict_get
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}

  run dict_get '' 'key' value
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}

  dict_init dict
  run dict_get "${dict}"
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}

  dict_destroy "${dict}"
}

@test 'dict_get - no outputs' {
  local dict

  dict_init dict
  run dict_get "${dict}" 'key'
  assert_failure ${LIB_BASH_ERROR_NO_OUTPUT}

  dict_destroy "${dict}"
}

@test 'dict_set - success' {
  local dict
  local value

  dict_init dict
  run dict_set "${dict}" 'key' 1
  assert_success
  assert_output ''

  dict_destroy "${dict}"
}

@test 'dict_set - invalid parameters' {
  local dict
  local value

  run dict_set
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}

  run dict_set '' 'key' 1
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}

  dict_init dict
  run dict_set "${dict}"
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}

  run dict_set "${dict}" 'key'
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}

  run dict_set "${dict}" '%%%' 1
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}

  dict_destroy "${dict}"
}

@test 'dict_unset - normal (1)' {
  local dict
  local value

  dict_init dict
  dict_set "${dict}" 'key' 1
  dict_get "${dict}" 'key' value
  assert_equal "${value}" 1

  dict_unset "${dict}" 'key'
  dict_get "${dict}" 'key' value
  assert_equal "${value}" ''

  dict_destroy "${dict}"
}

@test 'dict_unset - normal (2)' {
  local dict
  local value

  dict_init dict
  dict_set "${dict}" 'key' 1
  dict_set "${dict}" 'keykey' 2
  dict_set "${dict}" '__key__' 3
  dict_set "${dict}" '_key_' 4
  dict_set "${dict}" 'keykeykey' 5

  dict_get "${dict}" 'key' value
  assert_equal "${value}" 1
  dict_get "${dict}" 'keykey' value
  assert_equal "${value}" 2
  dict_get "${dict}" '__key__' value
  assert_equal "${value}" 3
  dict_get "${dict}" '_key_' value
  assert_equal "${value}" 4
  dict_get "${dict}" 'keykeykey' value
  assert_equal "${value}" 5

  dict_unset "${dict}" 'key'
  dict_get "${dict}" 'key' value
  assert_equal "${value}" ''
  dict_get "${dict}" 'keykey' value
  assert_equal "${value}" 2
  dict_get "${dict}" '__key__' value
  assert_equal "${value}" 3
  dict_get "${dict}" '_key_' value
  assert_equal "${value}" 4
  dict_get "${dict}" 'keykeykey' value
  assert_equal "${value}" 5

  dict_unset "${dict}" '__key__'
  dict_get "${dict}" 'key' value
  assert_equal "${value}" ''
  dict_get "${dict}" 'keykey' value
  assert_equal "${value}" 2
  dict_get "${dict}" '__key__' value
  assert_equal "${value}" ''
  dict_get "${dict}" '_key_' value
  assert_equal "${value}" 4
  dict_get "${dict}" 'keykeykey' value
  assert_equal "${value}" 5

  dict_unset "${dict}" 'keykeykey'
  dict_get "${dict}" 'key' value
  assert_equal "${value}" ''
  dict_get "${dict}" 'keykey' value
  assert_equal "${value}" 2
  dict_get "${dict}" '__key__' value
  assert_equal "${value}" ''
  dict_get "${dict}" '_key_' value
  assert_equal "${value}" 4
  dict_get "${dict}" 'keykeykey' value
  assert_equal "${value}" ''

  dict_unset "${dict}" 'keykey'
  dict_get "${dict}" 'key' value
  assert_equal "${value}" ''
  dict_get "${dict}" 'keykey' value
  assert_equal "${value}" ''
  dict_get "${dict}" '__key__' value
  assert_equal "${value}" ''
  dict_get "${dict}" '_key_' value
  assert_equal "${value}" 4
  dict_get "${dict}" 'keykeykey' value
  assert_equal "${value}" ''

  dict_unset "${dict}" '_key_'
  dict_get "${dict}" 'key' value
  assert_equal "${value}" ''
  dict_get "${dict}" 'keykey' value
  assert_equal "${value}" ''
  dict_get "${dict}" '__key__' value
  assert_equal "${value}" ''
  dict_get "${dict}" '_key_' value
  assert_equal "${value}" ''
  dict_get "${dict}" 'keykeykey' value
  assert_equal "${value}" ''

  dict_destroy "${dict}"
}

@test 'dict_unset - success' {
  local dict

  dict_init dict
  dict_set "${dict}" 'key' 1
  run dict_unset "${dict}" 'key'
  assert_success
  assert_output ''

  dict_destroy "${dict}"
}

@test 'dict_unset - duplicate unset' {
  local dict

  dict_init dict
  dict_set "${dict}" 'key' 1
  run dict_unset "${dict}" 'key'
  assert_success
  assert_output ''

  run dict_unset "${dict}" 'key'
  assert_success
  assert_output ''

  dict_destroy "${dict}"
}

@test 'dict_unset - invalid key' {
  local dict

  dict_init dict
  run dict_unset "${dict}" '###'
  assert_success
  assert_output ''

  dict_destroy "${dict}"
}

@test 'dict_unset - invalid parameters' {
  local dict

  run dict_unset
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}

  dict_init dict
  run dict_unset "${dict}"
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}

  run dict_unset '' 'key'
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}

  dict_destroy "${dict}"
}

@test 'dict_count - normal' {
  local dict
  local count=0

  dict_init dict
  dict_set "${dict}" '1' 1
  dict_set "${dict}" '2' 2
  dict_set "${dict}" '3' 3

  dict_count "${dict}" count
  assert_equal ${count} 3

  dict_unset "${dict}" '3'
  dict_count "${dict}" count
  assert_equal ${count} 2

  dict_unset "${dict}" '2'
  dict_count "${dict}" count
  assert_equal ${count} 1

  dict_unset "${dict}" '1'
  dict_count "${dict}" count
  assert_equal ${count} 0

  dict_destroy "${dict}"
}

@test 'dict_count - success' {
  local dict
  local count=0

  dict_init dict
  run dict_count "${dict}" count
  assert_success
  assert_output ''

  dict_destroy "${dict}"
}

@test 'dict_count - invalid parameters' {
  local count

  run dict_count
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}

  run dict_count '' count
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}
}

@test 'dict_count - no outputs' {
  local dict

  dict_init dict
  run dict_count "${dict}"
  assert_failure ${LIB_BASH_ERROR_NO_OUTPUT}

  dict_destroy "${dict}"
}

@test 'dict_keys - normal' {
  local dict
  local keys=('xxx')

  dict_init dict

  dict_keys "${dict}" keys
  assert_equal ${#keys[@]} 0

  dict_set "${dict}" 'key_1' 1
  dict_set "${dict}" 'key_2' 2
  dict_set "${dict}" 'key_3' 3
  dict_keys "${dict}" keys
  assert_equal ${#keys[@]} 3
  assert_equal "${keys[0]}" 'key_1'
  assert_equal "${keys[1]}" 'key_2'
  assert_equal "${keys[2]}" 'key_3'

  dict_destroy "${dict}"
}

@test 'dict_keys - success' {
  local dict
  local keys

  dict_init dict
  run dict_keys "${dict}" keys
  assert_success
  assert_output ''

  dict_destroy "${dict}"
}

@test 'dict_keys - invalid parameters' {
  local keys

  run dict_keys
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}

  run dict_keys '' keys
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}
}

@test 'dict_keys - no outputs' {
  local dict

  dict_init dict
  run dict_keys "${dict}"
  assert_failure ${LIB_BASH_ERROR_NO_OUTPUT}

  dict_destroy "${dict}"
}

@test 'dict_values - normal' {
  local dict
  local values=('xxx')

  dict_init dict

  dict_values "${dict}" values
  assert_equal ${#values[@]} 0

  dict_set "${dict}" 'key_1' 1
  dict_set "${dict}" 'key_2' 2
  dict_set "${dict}" 'key_3' 3
  dict_values "${dict}" values
  assert_equal ${#values[@]} 3
  assert_equal "${values[0]}" 1
  assert_equal "${values[1]}" 2
  assert_equal "${values[2]}" 3

  dict_destroy "${dict}"
}

@test 'dict_values - special characters' {
  local dict
  local values=()
  local expect

  dict_init dict
  dict_set "${dict}" '1' '"'
  dict_set "${dict}" '2' '\'
  dict_set "${dict}" '3' '$'
  dict_set "${dict}" '4' '@'
  dict_set "${dict}" '5' "x\nx"
  dict_set "${dict}" '6' "\n"

  dict_values "${dict}" values
  assert_equal ${#values[@]} 6
  assert_equal "${values[0]}" '"'
  assert_equal "${values[1]}" '\'
  assert_equal "${values[2]}" '$'
  assert_equal "${values[3]}" '@'
  assert_equal "${values[4]}" "$(printf "x\nx")"
  printf -v expect "\n"
  assert_equal "${values[5]}" "${expect}"

  dict_destroy "${dict}"
}

@test 'dict_values - empty string' {
  local dict
  local values=()

  dict_init dict
  dict_set "${dict}" 'key' ''
  dict_values "${dict}" values
  assert_equal ${#values[@]} 1
  assert_equal "${values[0]}" ''

  dict_destroy "${dict}"
}

@test 'dict_values - UTF-8' {
  local dict
  local value

  dict_init dict
  dict_set "${dict}" '1' '一'
  dict_set "${dict}" '2' '二'
  dict_set "${dict}" '3' '三'
  dict_values "${dict}" values
  assert_equal ${#values[@]} 3
  assert_equal "${values[0]}" '一'
  assert_equal "${values[1]}" '二'
  assert_equal "${values[2]}" '三'

  dict_destroy "${dict}"
}

@test 'dict_values - success' {
  local dict
  local values

  dict_init dict
  run dict_values "${dict}" values
  assert_success
  assert_output ''

  dict_destroy "${dict}"
}

@test 'dict_values - invalid parameters' {
  local values

  run dict_values
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}

  run dict_values '' values
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}
}

@test 'dict_values - no outputs' {
  local dict

  dict_init dict
  run dict_values "${dict}"
  assert_failure ${LIB_BASH_ERROR_NO_OUTPUT}

  dict_destroy "${dict}"
}

@test 'dict_clear - normal' {
  local dict
  local value

  dict_init dict
  dict_set "${dict}" 'key' 1
  dict_set "${dict}" 'keykey' 2
  dict_set "${dict}" '__key__' 3
  dict_set "${dict}" '_key_' 4
  dict_set "${dict}" 'keykeykey' 5

  dict_get "${dict}" 'key' value
  assert_equal "${value}" 1
  dict_get "${dict}" 'keykey' value
  assert_equal "${value}" 2
  dict_get "${dict}" '__key__' value
  assert_equal "${value}" 3
  dict_get "${dict}" '_key_' value
  assert_equal "${value}" 4
  dict_get "${dict}" 'keykeykey' value
  assert_equal "${value}" 5

  dict_clear "${dict}"
  dict_get "${dict}" 'key' value
  assert_equal "${value}" ''
  dict_get "${dict}" 'keykey' value
  assert_equal "${value}" ''
  dict_get "${dict}" '__key__' value
  assert_equal "${value}" ''
  dict_get "${dict}" '_key_' value
  assert_equal "${value}" ''
  dict_get "${dict}" 'keykeykey' value
  assert_equal "${value}" ''

  dict_destroy "${dict}"
}

@test 'dict_clear - success' {
  local dict
  local value

  dict_init dict
  dict_set "${dict}" 'key' 1
  dict_set "${dict}" 'keykey' 2
  dict_set "${dict}" '__key__' 3
  dict_set "${dict}" '_key_' 4
  dict_set "${dict}" 'keykeykey' 5

  run dict_clear "${dict}"
  assert_success
  assert_output ''

  dict_destroy "${dict}"
}

@test 'dict_clear - invalid parameters' {
  run dict_clear
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}

  run dict_clear 'xxx'
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}
}
