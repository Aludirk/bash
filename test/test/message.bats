load "${BATS_TEST_DIRNAME}/../bats-support/load.bash"
load "${BATS_TEST_DIRNAME}/../bats-assert/load.bash"

source "${BATS_TEST_DIRNAME}/../../message.sh"

teardown() {
  rm -f input.txt
}

@test 'message - simple default messge' {
  run message 'Hello'

  assert_output "$(printf "\e[0;30m%b\e[0m\n" 'Hello')"
}

@test 'message - special characters' {
  run message "A\"B\\C\$D\nE\n"

  assert_output "$(printf "\e[0;30m%b\e[0m\n" "A\"B\\C\$D\nE\n")"
}

@test 'message - empty string' {
  run message ''

  assert_output "$(printf "\e[0;30m\e[0m\n")"
}

@test 'message - UTF-8' {
  run message '你好嗎？'

  assert_output "$(printf "\e[0;30m你好嗎？\e[0m\n")"
}

@test 'message - foreground color message' {
  run message -f ${COLOR_BLACK} "Hello\nBye"

  assert_output "$(printf "\e[0;30m%b\e[0m\n" "Hello\nBye")"
}

@test 'message - background color message' {
  run message -b ${COLOR_YELLOW} 'Good Bye "World"'

  assert_output "$(printf "\e[0;30;43m%b\e[0m\n" 'Good Bye "World"')"
}

@test 'message - bright text' {
  run message -f ${COLOR_WHITE} -t 'Hello World'

  assert_output "$(printf "\e[1;37m%b\e[0m\n" 'Hello World')"
}

@test 'message - newline' {
  run message -n 'Hello World'

  assert_output "$(printf "\e[0;30m%b\e[0m" 'Hello World')"
}

@test 'message - all options' {
  run message -t -f ${COLOR_BLUE} -b ${COLOR_MAGENTA} -n 'TEST'

  assert_output "$(printf "\e[1;34;45m%b\e[0m" 'TEST')"
}

@test 'message - success' {
  run message 'Hello'

  assert_success
}

@test 'message - invalid parameters' {
  run message

  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}
}

@test 'message - invalid options' {
  run message -x 'TEST'

  assert_failure ${LIB_BASH_ERROR_INVALID_OPTION}
}

@test 'info - normal' {
  run info 'information'

  assert_output "$(printf "\e[1;32m%b\e[0m\n" 'information')"
}

@test 'info - special characters' {
  run info "A\"B\\C\$D\nE\n"

  assert_output "$(printf "\e[1;32m%b\e[0m\n" "A\"B\\C\$D\nE\n")"
}

@test 'info - empty string' {
  run info ''

  assert_output "$(printf "\e[1;32m\e[0m\n")"
}

@test 'info - UTF-8' {
  run info '資訊'

  assert_output "$(printf "\e[1;32m資訊\e[0m\n")"
}

@test 'info - alter color' {
  export LIB_BASH_INFO_COLOR=${COLOR_WHITE}
  run info 'information'

  assert_output "$(printf "\e[1;37m%b\e[0m\n" 'information')"
  export LIB_BASH_INFO_COLOR=${COLOR_GREEN}
}

@test 'info - success' {
  run info 'information'

  assert_success
}

@test 'info - invalid parameters' {
  run info

  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}
}

@test 'error - normal' {
  run error 'error msg' 2>&1

  assert_output "$(printf "\e[1;37;41m%b\e[0m\n" 'error msg')"
}

@test 'error - special characters' {
  run error "A\"B\\C\$D\nE\n"

  assert_output "$(printf "\e[1;37;41m%b\e[0m\n" "A\"B\\C\$D\nE\n")"
}

@test 'error - empty string' {
  run error ''

  assert_output "$(printf "\e[1;37;41m\e[0m\n")"
}

@test 'error - UTF-8' {
  run error '錯誤'

  assert_output "$(printf "\e[1;37;41m錯誤\e[0m\n")"
}

@test 'error - alter color' {
  export LIB_BASH_ERROR_FG=0
  export LIB_BASH_ERROR_BG=7
  run error 'error msg' 2>&1

  assert_output "$(printf "\e[1;30;47m%b\e[0m\n" 'error msg')"
  export LIB_BASH_ERROR_FG=${COLOR_WHITE}
  export LIB_BASH_ERROR_BG=${COLOR_RED}
}

@test 'error - success' {
  run error 'error msg' 2>&1

  assert_success
}

@test 'error - invalid parameters' {
  run error

  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}
}

@test 'question - normal (output)' {
  local answer

  printf "\n" > input.txt
  run question 'Please give me the "answer": ' answer < input.txt

  assert_output "$(printf "\e[1;36m%b\e[0m" 'Please give me the "answer": ')"
}

@test 'question - normal (answer)' {
  local answer

  printf "The answer is \"answer\"\n" > input.txt
  question 'Please give me the "answer": ' answer < input.txt

  assert_equal "${answer}" 'The answer is "answer"'
}

@test 'question - special characters (question)' {
  local answer

  printf "\n" > input.txt
  run question "A\"B\\C\$D\nE\n" answer < input.txt

  assert_output "$(printf "\e[1;36m%b\e[0m" "A\"B\\C\$D\nE\n")"
}

@test 'question - special characters (answer)' {
  local answer

  printf "ABC\"DEF\\GHI\$JKL\n" > input.txt
  question 'Please give me the "answer": ' answer < input.txt

  assert_equal "${answer}" 'ABC"DEF\GHI$JKL'
}

@test 'question - empty string (question)' {
  local answer

  printf "\n" > input.txt
  run question '' answer < input.txt

  assert_output "$(printf "\e[1;36m\e[0m")"
}

@test 'question - empty string (answer)' {
  local answer='xxx'

  printf "\n" > input.txt
  question 'Please give me the "answer":' answer < input.txt

  assert_equal "${answer}" ''
}

@test 'question - UTF-8 (question)' {
  local answer

  printf "\n" > input.txt
  run question '你叫咩名？' answer < input.txt

  assert_output "$(printf "\e[1;36m你叫咩名？\e[0m")"
}

@test 'question - UTF-8 (answer)' {
  local answer

  printf "海綿寶寶\n" > input.txt
  question 'Please give me the "answer":' answer < input.txt

  assert_equal "${answer}" '海綿寶寶'
}

@test 'question - alter color' {
  local answer

  export LIB_BASH_QUESTION_COLOR=7
  printf "\n" > input.txt
  run question 'Please give me the "answer": ' answer < input.txt

  assert_output "$(printf "\e[1;37m%b\e[0m" 'Please give me the "answer": ')"
  export LIB_BASH_QUESTION_COLOR=6
}

@test 'question - success' {
  local answer

  printf "\n" > input.txt
  run question 'Please give me the "answer": ' answer < input.txt

  assert_success
}

@test 'question - invalid parameters' {
  run question

  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}
}

@test 'question - no outputs' {
  printf "\n" > input.txt
  run question 'Question' < input.txt

  assert_failure ${LIB_BASH_ERROR_NO_OUTPUT}
}
