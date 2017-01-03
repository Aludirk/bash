load "${BATS_TEST_DIRNAME}/../bats-support/load.bash"
load "${BATS_TEST_DIRNAME}/../bats-assert/load.bash"

source "${BATS_TEST_DIRNAME}/../../command.sh"

@test "get_option - normal" {
  local args=("-a" "--beta" "-c" "ccc" "--delta=ddd" "-eeee" "p1" "p2")
  local options=()
  local param=()

  get_option "ab[beta]c:d[delta]:e:" args[@] options param
  assert_equal ${#options[@]} 5
  assert_equal "${options[0]}" "a:"
  assert_equal "${options[1]}" "b:"
  assert_equal "${options[2]}" "c:ccc"
  assert_equal "${options[3]}" "d:ddd"
  assert_equal "${options[4]}" "e:eee"
  assert_equal ${#param[@]} 2
  assert_equal "${param[0]}" "p1"
  assert_equal "${param[1]}" "p2"
}

@test "get_option - '--' (1)" {
  local args=("-a" "--beta" "-c" "ccc" "--delta=ddd" "-eeee" "--" "p1" "p2")
  local options=()
  local param=()

  get_option "ab[beta]c:d[delta]:e:" args[@] options param
  assert_equal ${#options[@]} 5
  assert_equal "${options[0]}" "a:"
  assert_equal "${options[1]}" "b:"
  assert_equal "${options[2]}" "c:ccc"
  assert_equal "${options[3]}" "d:ddd"
  assert_equal "${options[4]}" "e:eee"
  assert_equal ${#param[@]} 2
  assert_equal "${param[0]}" "p1"
  assert_equal "${param[1]}" "p2"
}

@test "get_option - '--' (2)" {
  local args=("-a" "--beta" "-c" "ccc" "--" "--delta=ddd" "-eeee" "p1" "p2")
  local options=()
  local param=()

  get_option "ab[beta]c:d[delta]:e:" args[@] options param
  assert_equal ${#options[@]} 3
  assert_equal "${options[0]}" "a:"
  assert_equal "${options[1]}" "b:"
  assert_equal "${options[2]}" "c:ccc"
  assert_equal ${#param[@]} 4
  assert_equal "${param[0]}" "--delta=ddd"
  assert_equal "${param[1]}" "-eeee"
  assert_equal "${param[2]}" "p1"
  assert_equal "${param[3]}" "p2"
}

@test "get_option - special chcaracters" {
  local args=("-a" 'ABC"DEF\GHI$JKL' 'JKL$GHI\DEF"ABC')
  local options=()
  local param=()

  get_option "a:" args[@] options param
  assert_equal ${#options[@]} 1
  assert_equal "${options[0]}" 'a:ABC"DEF\GHI$JKL'
  assert_equal ${#param[@]} 1
  assert_equal "${param[0]}" 'JKL$GHI\DEF"ABC'
}

@test "get_option - success" {
  local args=("-a" "--beta" "-c" "ccc" "--delta=ddd" "-eeee" "p1" "p2")
  local options=()
  local param=()

  run get_option "ab[beta]c:d[delta]:e:f[find_sth]" args[@] options param
  assert_success
  assert_output ""
}

@test "get_option - invalid parameters" {
  local args=()
  local options=()
  local param=()

  run get_option
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}

  run get_option "a"
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}

  run get_option "" args[@] options param
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}

  run get_option "a#b" args[@] options param
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}

  run get_option "a[a]" args[@] options param
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}

  run get_option "a[_a]" args[@] options param
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}

}

@test "get_option - invalid options" {
  local args=("-a" "-z" "--beta" "--option" "--data=ddd" "-cccc" "p1" "p2")
  local options=()
  local param=()

  run get_option "ab[beta]c:d[delta]:e:" args[@] options param
  assert_failure ${LIB_BASH_ERROR_INVALID_OPTION}
}

@test "get_option - no outputs" {
  run get_option "ab[beta]c:d[delta]:e:" args[@]
  assert_failure ${LIB_BASH_ERROR_NO_OUTPUT}

  run get_option "ab[beta]c:d[delta]:e:" args[@] options
  assert_failure ${LIB_BASH_ERROR_NO_OUTPUT}
}

@test "parse_option - normal" {
  local option="c:ccc"
  local opt=""
  local data=""

  parse_option "${option}" opt data
  assert_equal "${opt}" "c"
  assert_equal "${data}" "ccc"
}

@test "parse_option - special characters" {
  local option='c:A"B\C$D'
  local opt=""
  local data=""

  parse_option "${option}" opt data
  assert_equal "${opt}" "c"
  assert_equal "${data}" 'A"B\C$D'
}

@test "parse_option - success" {
  local option="c:ccc"
  local opt=""
  local data=""

  run parse_option "${option}" opt data
  assert_success
  assert_output ""
}

@test "parse_option - invalid parameters" {
  local option="o:"
  local opt=""
  local data=""

  run parse_option
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}

  run parse_option "" opt data
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}
}

@test "parse_option - no outputs" {
  local option="o:"
  local opt=""

  run parse_option "${option}"
  assert_failure ${LIB_BASH_ERROR_NO_OUTPUT}

  run parse_option "${option}" opt
  assert_failure ${LIB_BASH_ERROR_NO_OUTPUT}
}

@test "option - script argument" {
  run "${BATS_TEST_DIRNAME}"/fixture/argument.sh -a --beta -c ccc --delta=ddd -eeee p1 p2
  assert_success
  assert_equal ${#lines[@]} 7
  assert_line -n 0 "Option:a Data:"
  assert_line -n 1 "Option:b Data:"
  assert_line -n 2 "Option:c Data:ccc"
  assert_line -n 3 "Option:d Data:ddd"
  assert_line -n 4 "Option:e Data:eee"
  assert_line -n 5 "Param:p1"
  assert_line -n 6 "Param:p2"
}

@test "option - function argument" {
  run argument -a --beta -c ccc --delta=ddd -eeee p1 p2
  assert_success
  assert_equal ${#lines[@]} 7
  assert_line -n 0 "Option:a Data:"
  assert_line -n 1 "Option:b Data:"
  assert_line -n 2 "Option:c Data:ccc"
  assert_line -n 3 "Option:d Data:ddd"
  assert_line -n 4 "Option:e Data:eee"
  assert_line -n 5 "Param:p1"
  assert_line -n 6 "Param:p2"
}

function argument()
{
  local args=("${@}")

  local options=()
  local params=()
  get_option "ab[beta]c:d[delta]:e:" args[@] options params
  exit_code=${?}
  if [[ ${exit_code} -ne 0 ]]; then
    return ${exit_code}
  fi

  local option=""
  for option in "${options[@]}"; do
    local opt=""
    local data=""
    parse_option "${option}" opt data
    printf "%s\n" "Option:${opt} Data:${data}"
  done

  local param=""
  for param in "${params[@]}"; do
    printf "%s\n" "Param:${param}"
  done
}
