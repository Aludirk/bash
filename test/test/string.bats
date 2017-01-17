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
  expect="$(printf '%b' "A\"BC\\DE\$FG@HI\nJK\n\x1f")"
  assert_equal "${result}" "${expect%$'\x1f'}"
}

@test 'implode_string - empty string' {
  local array=('' '' '')
  local result

  implode_string array[@] ',' result
  assert_equal "${result}" ',,'
}

@test 'implode_string - UTF-8' {
  local array=('你' '好' '嗎' '？')
  local result

  implode_string array[@] '' result
  assert_equal "${result}" '你好嗎？'
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

@test 'explode_string - special characters in string (1)' {
  local result
  local expect=''

  explode_string "A\"A B\\B C\$C D@D E\nE F\n" ' ' result
  assert_equal ${#result[@]} 6
  assert_equal "${result[0]}" 'A"A'
  assert_equal "${result[1]}" 'B\B'
  assert_equal "${result[2]}" 'C$C'
  assert_equal "${result[3]}" 'D@D'
  assert_equal "${result[4]}" "$(printf '%b' "E\nE")"
  expect="$(printf "F\n\x1f")"
  assert_equal "${result[5]}" "${expect%$'\x1f'}"
}

@test 'explode_string - special characters in string (2)' {
  local result
  local expect

  explode_string "\n \n" ' ' result
  assert_equal ${#result[@]} 2
  printf -v expect "\n"
  assert_equal "${result[0]}" "${expect}"
  assert_equal "${result[1]}" "${expect}"
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

@test 'explode_string - UTF-8' {
  local result

  explode_string '你，好，嗎' '，' result
  assert_equal ${#result[@]} 3
  assert_equal "${result[0]}" '你'
  assert_equal "${result[1]}" '好'
  assert_equal "${result[2]}" '嗎'
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

@test 'escape_string - UTF-8' {
  local result

  escape_string -e '？' '你好嗎？' result
  assert_equal "${result}" '你好嗎\？'
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

@test 'match_string - normal' {
  local is_match

  match_string 'Hello World !!!' '\w+ \w+ !!!' '' is_match
  assert_equal ${is_match} true
}

@test 'match_string - special characters (1)' {
  local is_match

  match_string "A\"B\\C^D\$E@F(G)H[I]J{K}L\nM\n" '.".\\.\^.\$.@.\(.\).\[.\].\{.\}.\s.\s' 's' is_match
  assert_equal ${is_match} true
}

@test 'match_string - special characters (2)' {
  local match

  match_string "\n" '\s' 's' is_match
  assert_equal ${is_match} true
}

@test 'match_string - empty string' {
  local is_match=true

  match_string '' '.+' '' is_match
  assert_equal ${is_match} false
}

@test 'match_string - UTF-8' {
  local is_match

  match_string '你好嗎？' '.{3}？' '' is_match
  assert_equal ${is_match} true
}

@test 'match_string - modifier (1)' {
  local is_match

  match_string "LINE1\nLINE2\nLINE3" 'LINE.+3' 's' is_match
  assert_equal ${is_match} true
}

@test 'match_string - modifier (2)' {
  local is_match=true

  match_string "LINE1\nLINE2\nLINE3" 'LINE.+3' '' is_match
  assert_equal ${is_match} false
}

@test 'match_string - match email (1)' {
  local is_match

  match_string 'example@email.com' '[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+' '' is_match
  assert_equal ${is_match} true
}

@test 'match_string - match email (2)' {
  local is_match=true

  match_string 'example@email' '[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+' '' is_match
  assert_equal ${is_match} false
}

@test 'match_string - match whole string only' {
  local is_match=true

  match_string 'ABC123DEF' '\d+[A-Z]+' '' is_match
  assert_equal ${is_match} false
}

@test 'match_string - match with start and end of string should be worked' {
  local is_match

  match_string 'ABC123DEF' '^[A-Z]+\d+[A-Z]+$' '' is_match
  assert_equal ${is_match} true
}

@test 'match_string - invalid parameters' {
  run match_string
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}

  run match_string 'Hello World !!!'
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}

  run match_string 'Hello World !!!' '!!!$'
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}

  run match_string 'Hello World !!!' '' ''
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}
}

@test 'match_string - no outputs' {
  run match_string 'Hello World !!!' '!!!$' ''
  assert_failure ${LIB_BASH_ERROR_NO_OUTPUT}
}

@test 'match_string - invalid regular expression' {
  local is_match

  run match_string 'Hello World !!!' '(' '' is_match
  assert_failure ${LIB_BASH_INVALID_REGEX}
  assert_output ''

  run match_string 'Hello World !!!' '.*' '#' is_match
  assert_failure ${LIB_BASH_INVALID_REGEX}
  assert_output ''
}

@test 'regex_string - normal' {
  local matched
  local group

  regex_string 'Hello World !!!' '(W\w+)' '' matched group
  assert_equal "${matched}" 'World'
  assert_equal "${#group[@]}" 1
  assert_equal "${group[0]}" 'World'
}

@test 'regex_string - special characters (1)' {
  local matched
  local group
  local expect

  regex_string "A\"B\\C^D\$E@F(G)H[I]J{K}L\nM\n" '\W' 'g' matched group
  printf -v expect "\n"
  assert_equal "${matched}" "${expect}"
  assert_equal "${#group[@]}" 13
  assert_equal "${group[0]}" '"'
  assert_equal "${group[1]}" '\'
  assert_equal "${group[2]}" '^'
  assert_equal "${group[3]}" '$'
  assert_equal "${group[4]}" '@'
  assert_equal "${group[5]}" '('
  assert_equal "${group[6]}" ')'
  assert_equal "${group[7]}" '['
  assert_equal "${group[8]}" ']'
  assert_equal "${group[9]}" '{'
  assert_equal "${group[10]}" '}'
  assert_equal "${group[11]}" "${expect}"
  assert_equal "${group[12]}" "${expect}"
}

@test 'regex_string - special characters (2)' {
  local matched
  local group
  local expect

  regex_string "\n" '(\s)' 's' matched group
  printf -v expect "\n"
  assert_equal "${matched}" "${expect}"
  assert_equal ${#group[@]} 1
  assert_equal "${group[0]}" "${expect}"
}

@test 'regex_string - empty string' {
  local matched='xxx'
  local group=('xxx')

  regex_string '' '(.+)' '' matched group
  assert_equal "${matched}" ''
  assert_equal ${#group[@]} 0
}

@test 'regex_string - UTF-8' {
  local matched
  local group

  regex_string '你好嗎？' '([^？])' 'g' matched group
  assert_equal "${matched}" '嗎'
  assert_equal ${#group[@]} 3
  assert_equal "${group[0]}" '你'
  assert_equal "${group[1]}" '好'
  assert_equal "${group[2]}" '嗎'
}

@test 'regex_string - match empty' {
  local matched='xxx'
  local group

  regex_string 'AB CD' '(?<=\w)(\W*?)(?=\w)' 'g' matched group
  assert_equal "${matched}" ''
  assert_equal ${#group[@]} 3
  assert_equal "${group[0]}" ''
  assert_equal "${group[1]}" ' '
  assert_equal "${group[2]}" ''
}

@test 'regex_string - modifier (1)' {
  local matched
  local group
  local expect

  regex_string "<tag>asdf</tag>\n<tag>jkl;</tag>" '^<tag>(.*)<\/tag>$' 's' matched group
  printf -v expect "<tag>asdf</tag>\n<tag>jkl;</tag>"
  assert_equal "${matched}" "${expect}"
  assert_equal ${#group[@]} 1
  printf -v expect "asdf</tag>\n<tag>jkl;"
  assert_equal "${group[0]}" "${expect}"
}

@test 'regex_string - modifier (2)' {
  local matched
  local group

  regex_string "<tag>asdf</tag>\n<tag>jkl;</tag>" '^<tag>(.*)<\/tag>$' 'gm' matched group
  assert_equal "${matched}" '<tag>jkl;</tag>'
  assert_equal ${#group[@]} 2
  assert_equal "${group[0]}" 'asdf'
  assert_equal "${group[1]}" 'jkl;'
}

@test 'regex_string - no capture groups' {
  local matched
  local group=('xxx')

  regex_string 'ABC123!@#' '\d+' '' matched group
  assert_equal "${matched}" '123'
  assert_equal ${#group[@]} 0
}

@test 'regex_string - match "1" (1)' {
  local matched
  local group=('xxx')

  regex_string '1' '\d' '' matched group
  assert_equal "${matched}" '1'
  assert_equal ${#group[@]} 0
}

@test 'regex_string - match "1" (2)' {
  local matched
  local group

  regex_string '1' '(\d)' '' matched group
  assert_equal "${matched}" '1'
  assert_equal ${#group[@]} 1
  assert_equal "${group[0]}" '1'
}

@test 'regex_string - email' {
  local matched
  local group

  regex_string "1. test@example.com\n2. test.test@example.com\n3. test_test@example.com.hk" '[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+' 'gm' matched group
  assert_equal "${matched}" 'test_test@example.com.hk'
  assert_equal ${#group[@]} 3
  assert_equal "${group[0]}" 'test@example.com'
  assert_equal "${group[1]}" 'test.test@example.com'
  assert_equal "${group[2]}" 'test_test@example.com.hk'
}

@test 'regex_string - backreference' {
  local matched
  local group

  regex_string "abc=abc\nabc=def\ndef=abc\ndef=def" '((abc|def)=\2)' 'gm' matched group
  assert_equal "${matched}" 'def=def'
  assert_equal ${#group[@]} 4
  assert_equal "${group[0]}" 'abc=abc'
  assert_equal "${group[1]}" 'abc'
  assert_equal "${group[2]}" 'def=def'
  assert_equal "${group[3]}" 'def'
}

@test 'regex_string - success' {
  local matched
  local group

  run regex_string 'Hello World !!!' '(W\w+)' '' matched group
  assert_success
  assert_output ''
}

@test 'regex_string - invalid parameters' {
  run regex_string
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}

  run regex_string 'Hello World !!!'
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}

  run regex_string 'Hello World !!!' '.*'
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}

  run regex_string 'Hello World !!!' '' ''
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}
}

@test 'regex_string - no outputs' {
  local matched

  run regex_string 'Hello World !!!' '.*' ''
  assert_failure ${LIB_BASH_ERROR_NO_OUTPUT}

  run regex_string 'Hello World !!!' '.*' '' matched
  assert_failure ${LIB_BASH_ERROR_NO_OUTPUT}
}

@test 'regex_string - invalid regular expression' {
  local matched
  local group

  run regex_string 'Hello World !!!' '(' '' matched group
  assert_failure ${LIB_BASH_INVALID_REGEX}
  assert_output ''

  run regex_string 'Hello World !!!' '.*' '#' matched group
  assert_failure ${LIB_BASH_INVALID_REGEX}
  assert_output ''
}

@test 'replace_string - normal' {
  local replaced

  replace_string 'Hello World !!!' 'H\w+' 'Good Night' '' replaced
  assert_equal "${replaced}" 'Good Night World !!!'
}

@test 'replace_string - special characters (1)' {
  local replaced

  replace_string "A\"B\\C^D\$E@F(G)H[I]J{K}L\nM\n" '\W' '-' 'g' replaced
  assert_equal "${replaced}" 'A-B-C-D-E-F-G-H-I-J-K-L-M-'
}

@test 'replace_string - special characters (2)' {
  local replaced
  local expect

  replace_string 'A.' '\.' "\"\\\\^\\\$@\n()[]{}\n" 'g' replaced
  printf -v expect "A\"\\^\$@\n()[]{}\n"
  assert_equal "${replaced}" "${expect}"
}

@test 'replace_string - empty string (1)' {
  local replaced

  replace_string '' '^$' 'HELLO' '' replaced
  assert_equal "${replaced}" 'HELLO'
}

@test 'replace_string - empty string (2)' {
  local replaced='xxx'

  replace_string 'HELLO' '^.*$' '' '' replaced
  assert_equal "${replaced}" ''
}

@test 'replace_string - UTF-8' {
  local replaced

  replace_string '男人' '.(?=人)' '女' 'g' replaced
  assert_equal "${replaced}" '女人'
}

@test 'replace_string - modifier' {
  local replaced

  replace_string "ABC\nDEF\nGHI" "\n" '\$' 'gs' replaced
  assert_equal "${replaced}" 'ABC$DEF$GHI'
}

@test 'replace_string - replace config file' {
  local replaced
  local CONFIG="$(cat "${BATS_TEST_DIRNAME}/fixture/template.conf"; printf $'\x1f')"
  local expect

  replace_string "${CONFIG%$'\x1f'}" '<HOST>' '127.0.0.1' 'g' replaced
  replace_string "${replaced}" '<PASSWORD>' '123456' 'g' replaced
  printf -v expect "host=127.0.0.1\ndatabase=127.0.0.1\npassword=123456\n\n"
  assert_equal "${replaced}" "${expect}"
}

@test 'replace_string - success' {
  local replaced

  run replace_string 'Hello World !!!' 'H\w+' 'Good Night' '' replaced
  assert_success
  assert_output ''
}

@test 'replace_string - invalid parameters' {
  run replace_string
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}

  run replace_string 'Hello World !!!'
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}

  run replace_string 'Hello World !!!' '.*'
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}

  run replace_string 'Hello World !!!' '.*' ''
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}

  run replace_string 'Hello World !!!' '' '' ''
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}
}

@test 'replace_string - no outputs' {
  run replace_string 'Hello World !!!' '.*' '' ''
  assert_failure ${LIB_BASH_ERROR_NO_OUTPUT}
}

@test 'replace_string - invalid regular expression' {
  local replaced

  run replace_string 'Hello World !!!' '(' '' '' replaced
  assert_failure ${LIB_BASH_INVALID_REGEX}
  assert_output ''

  run replace_string 'Hello World !!!' '.*' '' '@' replaced
  assert_failure ${LIB_BASH_INVALID_REGEX}
  assert_output ''
}
