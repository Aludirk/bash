load "${BATS_TEST_DIRNAME}/../bats-support/load.bash"
load "${BATS_TEST_DIRNAME}/../bats-assert/load.bash"

source "${BATS_TEST_DIRNAME}/../../message.sh"

@test 'message - simple default messge' {
  run message 'Hello'

  assert_output "$(printf "\e[0;30m%b\e[0m\n" 'Hello')"
}

@test 'message - special characters' {
  run message "A\"B\\C\$D\nE\n"

  assert_output "$(printf "\e[0;30m%b\e[0m\n" "A\"B\\C\$D\nE\n")"
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

  pushd "${BATS_TEST_DIRNAME}/fixture" &> /dev/null
  run question 'Please give me the "answer": ' answer < answer.txt
  popd &> /dev/null

  assert_output "$(printf "\e[1;36m%b\e[0m" 'Please give me the "answer": ')"
}

@test 'question - normal (answer)' {
  local answer

  pushd "${BATS_TEST_DIRNAME}/fixture" &> /dev/null
  question 'Please give me the "answer": ' answer < answer.txt
  popd &> /dev/null

  assert_equal "${answer}" 'The answer is "answer"'
}

@test 'question - special characters (question)' {
  local answer

  pushd "${BATS_TEST_DIRNAME}/fixture" &> /dev/null
  run question "A\"B\\C\$D\nE\n" answer < answer.txt
  popd &> /dev/null

  assert_output "$(printf "\e[1;36m%b\e[0m" "A\"B\\C\$D\nE\n")"
}

@test 'question - special characters (answer)' {
  local answer

  pushd "${BATS_TEST_DIRNAME}/fixture" &> /dev/null
  question 'Please give me the "answer": ' answer < special_answer.txt
  popd &> /dev/null

  assert_equal "${answer}" 'ABC"DEF\GHI$JKL'
}

@test 'question - alter color' {
  local answer

  export LIB_BASH_QUESTION_COLOR=7
  pushd "${BATS_TEST_DIRNAME}/fixture" &> /dev/null
  run question 'Please give me the "answer": ' answer < answer.txt
  popd &> /dev/null

  assert_output "$(printf "\e[1;37m%b\e[0m" 'Please give me the "answer": ')"
  export LIB_BASH_QUESTION_COLOR=6
}

@test 'question - success' {
  local answer

  pushd "${BATS_TEST_DIRNAME}/fixture" &> /dev/null
  run question 'Please give me the "answer": ' answer < answer.txt
  popd &> /dev/null

  assert_success
}

@test 'question - invalid parameters' {
  run question

  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}
}

@test 'question - no outputs' {
  pushd "${BATS_TEST_DIRNAME}/fixture" &> /dev/null
  run question 'Question' < answer.txt
  popd &> /dev/null

  assert_failure ${LIB_BASH_ERROR_NO_OUTPUT}
}
