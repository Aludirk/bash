load "${BATS_TEST_DIRNAME}/../bats-support/load.bash"
load "${BATS_TEST_DIRNAME}/../bats-assert/load.bash"

source "${BATS_TEST_DIRNAME}/../../string.sh"

@test "implode_string - normal" {
  local array=("Hello" "World" "!!!")
  local result

  implode_string array[@] "_" result
  assert_equal "${result}" "Hello_World_!!!"
}

@test "implode_string - with double quote" {
  local array=("\"Hello\"" "\"World\"" "\"!!!\"")
  local result

  implode_string array[@] "\"" result
  assert_equal "${result}" "\"Hello\"\"\"World\"\"\"!!!\""
}

@test "implode_string - with space" {
  local array=("Hello" "World" "! ! !")
  local result

  implode_string array[@] " " result
  assert_equal "${result}" "Hello World ! ! !"
}

@test "implode_string - with newline" {
  local array=("Hello" "World" "!!!")
  local result

  implode_string array[@] $'\n' result
  assert_equal "${result}" "$(printf "Hello\nWorld\n!!!")"
}

@test "implode_string - with string" {
  local array=("Hello" "World" "!!!")
  local result

  implode_string array[@] " and " result
  assert_equal "${result}" "Hello and World and !!!"
}

@test "implode_string - with 0 elements" {
  local array=()

  implode_string array[@] " " result
  assert_equal "${result}" ""
}

@test "implode_string - with 1 element" {
  local array=("HI")
  local result

  implode_string array[@] " " result
  assert_equal "${result}" "HI"
}

@test "implode_string - success" {
  local array=("ABC" "DEF")
  local result

  run implode_string array[@] "," result
  assert_success
  assert_output ""
}

@test "implode_string - invalid parameters" {
  local array=("ABC" "DEF")

  run implode_string
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}

  run implode_string array[@]
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}

  run implode_string array[@] ""
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}
}

@test "implode_string - no outputs" {
  local array=("ABC" "DEF")

  run implode_string array[@] ","
  assert_failure ${LIB_BASH_ERROR_NO_OUTPUT}
}

@test "explode_string - normal" {
  local result

  explode_string "Hello World !!!" " " result
  assert_equal ${#result[@]} 3
  assert_equal "${result[0]}" "Hello"
  assert_equal "${result[1]}" "World"
  assert_equal "${result[2]}" "!!!"
}

@test "explode_string - with double quote" {
  local result

  explode_string "\\\"Hello\\\" \\\"World\\\" \\\"!!!\\\"" " " result
  assert_equal ${#result[@]} 3
  assert_equal "${result[0]}" "\"Hello\""
  assert_equal "${result[1]}" "\"World\""
  assert_equal "${result[2]}" "\"!!!\""
}

@test "explode_string - with dilimiter list" {
  local result

  explode_string "ABC,DEF GHI|JKL" ", |" result
  assert_equal ${#result[@]} 4
  assert_equal "${result[0]}" "ABC"
  assert_equal "${result[1]}" "DEF"
  assert_equal "${result[2]}" "GHI"
  assert_equal "${result[3]}" "JKL"
}

@test "explode_string - success" {
  local result

  run explode_string "ABC DEF GHI" " " result
  assert_success
  assert_output ""

  run explode_string "" " " result
  assert_success
  assert_output ""
}

@test "explode_string - invalid parameters" {
  run explode_string
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}

  run explode_string "ABC DEF GHI"
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}

  run explode_string "ABC DEF GHI" ""
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}
}

@test "explode_string - no outputs" {
  run explode_string "ABC DEF GHI" " "
  assert_failure ${LIB_BASH_ERROR_NO_OUTPUT}
}
