load "${BATS_TEST_DIRNAME}/../bats-support/load.bash"
load "${BATS_TEST_DIRNAME}/../bats-assert/load.bash"

source "${BATS_TEST_DIRNAME}/../../string.sh"

@test 'implode_string - normal' {
  local array=('Hello' 'World' '!!!')
  local result

  implode_string array[@] '_' result
  assert_equal "${result}" 'Hello_World_!!!'
}

@test 'implode_string - with double quote' {
  local array=('"Hello"' '"World"' '"!!!"')
  local result

  implode_string array[@] '"' result
  assert_equal "${result}" '"Hello"""World"""!!!"'
}

@test 'implode_string - with space' {
  local array=('Hello' 'World' '! ! !')
  local result

  implode_string array[@] ' ' result
  assert_equal "${result}" 'Hello World ! ! !'
}

@test 'implode_string - with newline (array)' {
  local array=("A\nB" "C\nD" "E\nF")
  local result

  implode_string array[@] ' ' result
  assert_equal "${result}" "$(printf '%b' "A\nB C\nD E\nF")"
}

@test 'implode_string - with newline (separator)' {
  local array=('Hello' 'World' '!!!')
  local result

  implode_string array[@] $'\n' result
  assert_equal "${result}" "$(printf '%b' "Hello\nWorld\n!!!")"
}

@test 'implode_string - with nothing' {
  local array=('Hello' 'World' '!!!')
  local result

  implode_string array[@] '' result
  assert_equal "${result}" "$(printf '%b' "HelloWorld!!!")"
}

@test 'implode_string - special characters' {
  local array=('A"B' 'C\D' 'E$F' 'G@H' "I\nJ" "K\n")
  local result
  local expect=''

  implode_string array[@] '' result
  expect="$(printf '%b' "A\"BC\\DE\$FG@HI\nJK\n\xff")"
  assert_equal "${result}" "${expect%$'\xff'}"
}

@test 'implode_string - empty string' {
  local array=('' '' '')
  local result

  implode_string array[@] ',' result
  assert_equal "${result}" ',,'
}

@test 'implode_string - empty string' {
  local array=('' '' '')
  local result

  implode_string array[@] ',' result
  assert_equal "${result}" ',,'
}

@test 'implode_string - with string' {
  local array=('Hello' 'World' '!!!')
  local result

  implode_string array[@] ' and ' result
  assert_equal "${result}" 'Hello and World and !!!'
}

@test 'implode_string - with 0 elements' {
  local array=()

  implode_string array[@] ' ' result
  assert_equal "${result}" ''
}

@test 'implode_string - with 1 element' {
  local array=('HI')
  local result

  implode_string array[@] ' ' result
  assert_equal "${result}" 'HI'
}

@test 'implode_string - success' {
  local array=('ABC' 'DEF')
  local result

  run implode_string array[@] ',' result
  assert_success
  assert_output ''
}

@test 'implode_string - invalid parameters' {
  local array=('ABC' 'DEF')

  run implode_string
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}

  run implode_string array[@]
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}
}

@test 'implode_string - no outputs' {
  local array=('ABC' 'DEF')

  run implode_string array[@] ','
  assert_failure ${LIB_BASH_ERROR_NO_OUTPUT}
}

@test 'explode_string - normal' {
  local result

  explode_string 'Hello World !!!' ' ' result
  assert_equal ${#result[@]} 3
  assert_equal "${result[0]}" 'Hello'
  assert_equal "${result[1]}" 'World'
  assert_equal "${result[2]}" '!!!'
}

@test 'explode_string - special characters in string' {
  local result
  local expect=''

  explode_string "A\"A B\\B C\$C D@D E\nE F\n" ' ' result
  assert_equal ${#result[@]} 6
  assert_equal "${result[0]}" 'A"A'
  assert_equal "${result[1]}" 'B\B'
  assert_equal "${result[2]}" 'C$C'
  assert_equal "${result[3]}" 'D@D'
  assert_equal "${result[4]}" "$(printf '%b' "E\nE")"
  expect="$(printf "F\n\xff")"
  assert_equal "${result[5]}" "${expect%$'\xff'}"
}

@test 'explode_string - special characters in delimiter' {
  local result

  explode_string "Hello\"World\\!^!\$!@!\n!(!)![!]!{!}!" $'"\^$@()[]{}\n' result
  assert_equal ${#result[@]} 13
  assert_equal "${result[0]}" 'Hello'
  assert_equal "${result[1]}" 'World'
  assert_equal "${result[2]}" '!'
  assert_equal "${result[3]}" '!'
  assert_equal "${result[4]}" '!'
  assert_equal "${result[5]}" '!'
  assert_equal "${result[6]}" '!'
  assert_equal "${result[7]}" '!'
  assert_equal "${result[8]}" '!'
  assert_equal "${result[9]}" '!'
  assert_equal "${result[10]}" '!'
  assert_equal "${result[11]}" '!'
  assert_equal "${result[12]}" '!'
}

@test 'explode_string - empty string (1)' {
  local result='xxx'

  explode_string '' ' ' result
  assert_equal ${#result[@]} 1
  assert_equal "${result[0]}" ''
}

@test 'explode_string - empty string (2)' {
  local result='xxx'

  explode_string '  ' ' ' result
  assert_equal ${#result[@]} 3
  assert_equal "${result[0]}" ''
  assert_equal "${result[1]}" ''
  assert_equal "${result[2]}" ''
}

@test 'explode_string - with double quote' {
  local result

  explode_string '"Hello" "World" "!!!"' ' ' result
  assert_equal ${#result[@]} 3
  assert_equal "${result[0]}" '"Hello"'
  assert_equal "${result[1]}" '"World"'
  assert_equal "${result[2]}" '"!!!"'
}

@test 'explode_string - with newline (string)' {
  local result

  explode_string "A\nB C\nD E\nF" ' ' result
  assert_equal ${#result[@]} 3
  assert_equal "${result[0]}" "$(printf '%b' "A\nB")"
  assert_equal "${result[1]}" "$(printf '%b' "C\nD")"
  assert_equal "${result[2]}" "$(printf '%b' "E\nF")"
}

@test 'explode_string - with newline (delimiter)' {
  local result

  explode_string "Hello\nWorld\n!!!" $'\n' result
  assert_equal ${#result[@]} 3
  assert_equal "${result[0]}" 'Hello'
  assert_equal "${result[1]}" 'World'
  assert_equal "${result[2]}" '!!!'
}

@test 'explode_string - with delimiter list' {
  local result

  explode_string 'ABC,DEF GHI|JKL' ', |' result
  assert_equal ${#result[@]} 4
  assert_equal "${result[0]}" 'ABC'
  assert_equal "${result[1]}" 'DEF'
  assert_equal "${result[2]}" 'GHI'
  assert_equal "${result[3]}" 'JKL'
}

@test 'explode_string - empty delimiter' {
  local result

  explode_string 'HELLO' '' result
  assert_equal ${#result[@]} 5
  assert_equal "${result[0]}" 'H'
  assert_equal "${result[1]}" 'E'
  assert_equal "${result[2]}" 'L'
  assert_equal "${result[3]}" 'L'
  assert_equal "${result[4]}" 'O'
}

@test 'explode_string - success' {
  local result

  run explode_string 'ABC DEF GHI' ' ' result
  assert_success
  assert_output ''

  run explode_string '' ' ' result
  assert_success
  assert_output ''
}

@test 'explode_string - invalid parameters' {
  run explode_string
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}

  run explode_string 'ABC DEF GHI'
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}
}

@test 'explode_string - no outputs' {
  run explode_string 'ABC DEF GHI' ' '
  assert_failure ${LIB_BASH_ERROR_NO_OUTPUT}
}

@test 'escape_string - normal' {
  local result

  escape_string 'ABC"DEF\GHI$JKL' result
  assert_equal "${result}" 'ABC\"DEF\\GHI\$JKL'
}

@test 'escape_string - define escape list' {
  local result

  escape_string -e '&,' 'ABC"D,F\G&I$JKL' result
  assert_equal "${result}" 'ABC"D\,F\G\&I$JKL'
}

@test 'escape_string - string with space' {
  local result

  escape_string -e '&,' 'A C"D,F\G&I$J L' result
  assert_equal "${result}" 'A C"D\,F\G\&I$J L'
}

@test 'escape_string - escape with space' {
  local result

  escape_string -e ' ' -- 'ABC DEF&GHI JKL' result
  assert_equal "${result}" 'ABC\ DEF&GHI\ JKL'
}

@test 'escape_string - string with newline' {
  local result
  local expect

  escape_string "ABC\"D\nF\\G\nI\$JKL\n" result
  printf -v expect '%b' "ABC\\\"D\nF\\\\\\\\G\nI\\\$JKL\n"
  assert_equal "${result}" "${expect}"
}

@test 'escape_string - empty string (string)' {
  local result='xxx'

  escape_string '' result
  assert_equal "${result}" ''
}

@test 'escape_string - empty string (escape) (1)' {
  local result='xxx'

  escape_string -e '' '' result
  assert_equal "${result}" ''
}

@test 'escape_string - empty string (escape) (2)' {
  local result='xxx'
  local expect

  escape_string -e '' "ABC\n" result
  printf -v expect "ABC\n"
  assert_equal "${result}" "${expect}"
}

@test 'escape_string - success' {
  local result

  run escape_string 'ABC"DEF\GHI$JKL' result
  assert_success
  assert_output ''
}

@test 'escape_string - invalid parameters' {
  run escape_string
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}

  run escape_string -e ' '
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}
}

@test 'escape_string - invalid options' {
  local result

  run escape_string -x ' ' 'ABC"DEF\GHI$JKL' result
  assert_failure ${LIB_BASH_ERROR_INVALID_OPTION}
}

@test 'escape_string - no outputs' {
  run escape_string -e ' ' 'ABC"DEF\GHI$JKL'
  assert_failure ${LIB_BASH_ERROR_NO_OUTPUT}
}
