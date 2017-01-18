load "${BATS_TEST_DIRNAME}/../bats-support/load.bash"
load "${BATS_TEST_DIRNAME}/../bats-assert/load.bash"

source "${BATS_TEST_DIRNAME}/../../env.sh"

@test 'load_env_file - normal' {
  load_env_file "${BATS_TEST_DIRNAME}/fixture/config.env"

  assert_equal "${TEST_STRING_A}" 'ABC'
  assert_equal "${TEST_STRING_B}" 'DEF'
  assert_equal ${TEST_NUMBER_A} 10
  assert_equal ${TEST_NUMBER_B} 5354
}

@test 'load_env_file - success' {
  run load_env_file "${BATS_TEST_DIRNAME}/fixture/config.env"

  assert_success
  assert_output ''
}

@test 'load_env_file - file does not exist' {
  run load_env_file
  assert_failure ${LIB_BASH_ERROR_FILE_NOT_EXIST}

  run load_env_file 'test.env'
  assert_failure ${LIB_BASH_ERROR_FILE_NOT_EXIST}
}
