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

@test 'select_option - normal (selection)' {
  local options=('Option 1' 'Option 2')
  local option=0

  printf "1\n" > input.txt
  run select_option 'Please choose:' options[@] option < input.txt
  assert_line -n 0 "$(printf "\e[1;32mPlease choose:\e[0m")"
  assert_line -n 1 '  1) Option 1'
  assert_line -n 2 '  2) Option 2'
  assert_line -n 3 "$(printf "\e[1;36m\e[1A\e[2K1-2 ? \e[0m")"
}

@test 'select_option - normal (option)' {
  local options=('Option 1' 'Option 2')
  local option=0

  printf "2\n" > input.txt
  select_option 'info' options[@] option < input.txt
  assert_equal ${option} 1
}

@test 'select_option - special characters (info)' {
  local options=('Option 1' 'Option 2')
  local option=0

  printf "1\n" > input.txt
  run select_option "\"\\\$\n@\n" options[@] option < input.txt
  assert_line -n 0 "$(printf "\e[1;32m\"\\\$")"
  assert_line -n 1 "$(printf '@')"
  assert_line -n 2 "$(printf "\e[0m")"
  assert_line -n 3 '  1) Option 1'
  assert_line -n 4 '  2) Option 2'
  assert_line -n 5 "$(printf "\e[1;36m\e[1A\e[2K1-2 ? \e[0m")"
}

@test 'select_option - special characters (option) (1)' {
  local options=('"' '\' '$' '@' "x\nx" "\n")
  local option=0

  printf "1\n" > 'input.txt'
  run select_option -o 'info' options[@] option < input.txt

  local line0="\e[1;32minfo\e[0m\n"
  local line1="  1) \"\n"
  local line2="  2) \\\\\n"
  local line3="  3) \$\n"
  local line4="  4) @\n"
  local line5="  5) x\nx\n"
  local line6="  6) \n\n"
  local line7="\n"
  local line8="\e[1;36m\e[1A\e[2K1-6 ? \e[0m"
  assert_output \
    "$(printf "${line0}${line1}${line2}${line3}${line4}${line5}${line6}${line7}${line8}")"
}

@test 'select_option - special characters (option) (2)' {
  local options=('"' '\' '$' '@' "x\nx" "\n")
  local option=0

  printf "1\n" > input.txt
  select_option -o 'info' options[@] option < input.txt
  assert_equal "${option}" '"'

  printf "2\n" > 'input.txt'
  select_option -o 'info' options[@] option < input.txt
  assert_equal "${option}" '\'

  printf "3\n" > 'input.txt'
  select_option -o 'info' options[@] option < input.txt
  assert_equal "${option}" '$'

  printf "4\n" > 'input.txt'
  select_option -o 'info' options[@] option < input.txt
  assert_equal "${option}" '@'

  printf "5\n" > 'input.txt'
  select_option -o 'info' options[@] option < input.txt
  assert_equal "${option}" "$(printf "x\nx")"

  printf "6\n" > 'input.txt'
  select_option -o 'info' options[@] option < input.txt
  printf -v expect "\n"
  assert_equal "${option}" "${expect}"
}

@test 'select_option - empty info' {
  local options=('Option 1' 'Option 2')
  local option=0

  printf "2\n" > input.txt
  run select_option '' options[@] option < input.txt
  assert_line -n 0 '  1) Option 1'
  assert_line -n 1 '  2) Option 2'
  assert_line -n 2 "$(printf "\e[1;36m\e[1A\e[2K1-2 ? \e[0m")"
}

@test 'select_option - empty option (1)' {
  local options=('' '')
  local option=0

  printf "1\n" > input.txt
  run select_option 'Please choose:' options[@] option < input.txt
  assert_line -n 0 "$(printf "\e[1;32mPlease choose:\e[0m")"
  assert_line -n 1 '  1) '
  assert_line -n 2 '  2) '
  assert_line -n 3 "$(printf "\e[1;36m\e[1A\e[2K1-2 ? \e[0m")"
}

@test 'select_option - empty option (2)' {
  local options=('' '')
  local option='xxx'

  printf "1\n" > input.txt
  select_option -o 'Please choose:' options[@] option < input.txt
  assert_equal "${option}" ''
}

@test 'select_option - UTF-8 (1)' {
  local options=('壹' '貳' '叄')
  local option=0

  printf "1\n" > input.txt
  run select_option '請選擇：' options[@] option < input.txt
  assert_line -n 0 "$(printf "\e[1;32m請選擇：\e[0m")"
  assert_line -n 1 '  1) 壹'
  assert_line -n 2 '  2) 貳'
  assert_line -n 3 '  3) 叄'
  assert_line -n 4 "$(printf "\e[1;36m\e[1A\e[2K1-3 ? \e[0m")"
}

@test 'select_option - UTF-8 (2)' {
  local options=('壹' '貳' '叄')
  local option=''

  printf "3\n" > input.txt
  select_option -o '請選擇：' options[@] option < input.txt
  assert_equal "${option}" '叄'
}

@test 'select_option - option' {
  local options=('Option 1' 'Option 2')
  local option=''

  printf "1\n" > input.txt
  select_option -o 'info' options[@] option < input.txt
  assert_equal "${option}" 'Option 1'

  printf "2\n" > input.txt
  select_option --option 'info' options[@] option < input.txt
  assert_equal "${option}" 'Option 2'
}

@test 'select_option - more than 10 options (1)' {
  local options=('I' 'II' 'III' 'IV' 'V' 'VI' 'VII' 'VIII' 'IX' 'X' 'XI' 'XII')
  local option=0

  printf "1\n" > input.txt
  run select_option 'Please choose:' options[@] option < input.txt
  assert_line -n 0 "$(printf "\e[1;32mPlease choose:\e[0m")"
  assert_line -n 1 '   1) I'
  assert_line -n 2 '   2) II'
  assert_line -n 3 '   3) III'
  assert_line -n 4 '   4) IV'
  assert_line -n 5 '   5) V'
  assert_line -n 6 '   6) VI'
  assert_line -n 7 '   7) VII'
  assert_line -n 8 '   8) VIII'
  assert_line -n 9 '   9) IX'
  assert_line -n 10 '  10) X'
  assert_line -n 11 '  11) XI'
  assert_line -n 12 '  12) XII'
  assert_line -n 13 "$(printf "\e[1;36m\e[1A\e[2K1-12 ? \e[0m")"
}

@test 'select_option - more than 10 options (2)' {
  local options=('I' 'II' 'III' 'IV' 'V' 'VI' 'VII' 'VII' 'IX' 'X' 'XI' 'XII')
  local option=0

  printf "12\n" > input.txt
  select_option 'Please choose:' options[@] option < input.txt
  assert_equal ${option} 11
}

@test 'select_option - repeat wrong input' {
  local options=('Option 1' 'Option 2')
  local option=0

  printf "\nA\n0\n3\n1.1\n1\n" > input.txt
  run select_option 'Please choose:' options[@] option < input.txt

  local expect_arr=("\e[1;32mPlease choose:\e[0m\n" \
    "  1) Option 1\n" \
    "  2) Option 2\n" \
    "\n" \
    "\e[1;36m\e[1A\e[2K1-2 ? \e[0m" \
    "\e[1;36m\e[1A\e[2K1-2 ? \e[0m" \
    "\e[1;36m\e[1A\e[2K1-2 ? \e[0m" \
    "\e[1;36m\e[1A\e[2K1-2 ? \e[0m" \
    "\e[1;36m\e[1A\e[2K1-2 ? \e[0m" \
    "\e[1;36m\e[1A\e[2K1-2 ? \e[0m" )
  local expect=''
  local index=0
  for index in "${!expect_arr[@]}"; do
    expect="${expect}${expect_arr[index]}"
  done
  assert_output "$(printf '%b' "${expect}")"
}

@test 'select_option - success' {
  local options=('Option 1' 'Option 2')
  local option=0

  printf "1\n" > input.txt
  run select_option 'Please choose:' options[@] option < input.txt
  assert_success
}

@test 'select_option - invalid parameters' {
  local options=()

  run select_option
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}
  assert_output ''

  run select_option 'info'
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}
  assert_output ''

  run select_option 'info' options[@]
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}
  assert_output ''

  options=('1')
  run select_option 'info' options[@]
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}
  assert_output ''
}

@test 'select_option - invalid options' {
  local options=('Option 1' 'Option 2')
  local option=0

  run select_option -x 'info' options[@] option
  assert_failure ${LIB_BASH_ERROR_INVALID_OPTION}
  assert_output ''
}

@test 'select_option - no outputs' {
  local options=('Option 1' 'Option 2')

  run select_option 'info' options[@]
  assert_failure ${LIB_BASH_ERROR_NO_OUTPUT}
  assert_output ''
}
