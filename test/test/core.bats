load "${BATS_TEST_DIRNAME}/../bats-support/load.bash"
load "${BATS_TEST_DIRNAME}/../bats-assert/load.bash"

source "${BATS_TEST_DIRNAME}/../../.core.sh"

setup() {
  LIB_BASH_DEBUG=true
}

teardown() {
  LIB_BASH_DEBUG=false
}

@test "error_code_func - Success" {
  run error_code_func ${BASH_SOURCE[0]} ${LINENO} 0
  assert_success
  assert_output ""
}

@test "error_code_func - Invalid parameters" {
  local line_no=${LINENO}; run error_code_func \
    ${BASH_SOURCE[0]} ${line_no} ${LIB_BASH_ERROR_INVALID_PARAM}
  local expect=$(printf "\e[1;37;41mInvalid parameters. (${BASH_SOURCE[0]}:${line_no})\e[0m\n")
  assert_failure ${LIB_BASH_ERROR_INVALID_PARAM}
  assert_output "${expect}"
}

@test "error_code_func - Invalid options" {
  local line_no=${LINENO}; run error_code_func \
    ${BASH_SOURCE[0]} ${line_no} ${LIB_BASH_ERROR_INVALID_OPTION}
  local expect=$(printf "\e[1;37;41mInvalid options. (${BASH_SOURCE[0]}:${line_no})\e[0m\n")
  assert_failure ${LIB_BASH_ERROR_INVALID_OPTION}
  assert_output "${expect}"
}

@test "error_code_func - No outputs" {
  local line_no=${LINENO}; run error_code_func \
    ${BASH_SOURCE[0]} ${line_no} ${LIB_BASH_ERROR_NO_OUTPUT}
  local expect=$(printf "\e[1;37;41mNo outputs. (${BASH_SOURCE[0]}:${line_no})\e[0m\n")
  assert_failure ${LIB_BASH_ERROR_NO_OUTPUT}
  assert_output "${expect}"
}

@test "error_code_func - unknown error" {
  local error_code=0
  for error_code in $(seq 1 2; seq 6 255); do
    run error_code_func ${BASH_SOURCE[0]} ${LINENO} ${error_code}
    assert_failure ${error_code}
    assert_output ""
  done
}
