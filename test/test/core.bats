load "${BATS_TEST_DIRNAME}/../bats-support/load.bash"
load "${BATS_TEST_DIRNAME}/../bats-assert/load.bash"

source "${BATS_TEST_DIRNAME}/../../.core.sh"

setup() {
  LIB_BASH_DEBUG=true
}

teardown() {
  LIB_BASH_DEBUG=false
}

@test "error_code_func - success" {
  run error_code_func ${BASH_SOURCE[0]} ${LINENO} 0
  assert_success
  assert_output ""
}

@test "error_code_func - invalid parameters" {
  local line_no=${LINENO}; run error_code_func \
    ${BASH_SOURCE[0]} ${line_no} ${LIB_BASH_ERROR_INVALID_PARAM}

  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}
  assert_output \
    "$(printf "\e[1;37;41mInvalid parameters. (${BASH_SOURCE[0]}:${line_no})\e[0m\n")"
}

@test "error_code_func - invalid options" {
  local line_no=${LINENO}; run error_code_func \
    ${BASH_SOURCE[0]} ${line_no} ${LIB_BASH_ERROR_INVALID_OPTION}

  assert_failure ${LIB_BASH_ERROR_INVALID_OPTION}
  assert_output \
    "$(printf "\e[1;37;41mInvalid options. (${BASH_SOURCE[0]}:${line_no})\e[0m\n")"
}

@test "error_code_func - no outputs" {
  local line_no=${LINENO}; run error_code_func \
    ${BASH_SOURCE[0]} ${line_no} ${LIB_BASH_ERROR_NO_OUTPUT}

  assert_failure ${LIB_BASH_ERROR_NO_OUTPUT}
  assert_output \
    "$(printf "\e[1;37;41mNo outputs. (${BASH_SOURCE[0]}:${line_no})\e[0m\n")"
}

@test "error_code_func - file does not exist" {
  local line_no=${LINENO}; run error_code_func \
    ${BASH_SOURCE[0]} ${line_no} ${LIB_BASH_ERROR_FILE_NOT_EXIST}

  assert_failure ${LIB_BASH_ERROR_FILE_NOT_EXIST}
  assert_output \
    "$(printf "\e[1;37;41mFile does not exist. (${BASH_SOURCE[0]}:${line_no})\e[0m\n")"
}

@test "error_code_func - unknown error" {
  local error_code=0
  for error_code in $(seq 1 2; seq 7 255); do
    run error_code_func ${BASH_SOURCE[0]} ${LINENO} ${error_code}
    assert_failure ${error_code}
    assert_output ""
  done
}
