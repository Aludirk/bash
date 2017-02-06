load "${BATS_TEST_DIRNAME}/../bats-support/load.bash"
load "${BATS_TEST_DIRNAME}/../bats-assert/load.bash"

source "${BATS_TEST_DIRNAME}/../../network.sh"

teardown() {
  rm -f input.txt
}

@test 'local_ip - no IPv4' {
  local ip='xxx'

  shopt -s expand_aliases
  alias ifconfig="cat ${BATS_TEST_DIRNAME}/fixture/ifconfig0.txt" # stub `ifconfig`
  local_ip ip
  assert_equal "${ip}" ''

  unalias ifconfig
}

@test 'local_ip - 1 IPv4' {
  local ip

  shopt -s expand_aliases
  alias ifconfig="cat ${BATS_TEST_DIRNAME}/fixture/ifconfig1.txt" # stub `ifconfig`
  local_ip ip
  assert_equal "${ip}" '192.168.10.100'

  unalias ifconfig
}

@test 'local_ip - N IPv4 (question)' {
  local ip

  shopt -s expand_aliases
  alias ifconfig="cat ${BATS_TEST_DIRNAME}/fixture/ifconfigN.txt" # stub `ifconfig`
  printf "1\n" > input.txt
  run local_ip ip < input.txt
  assert_line -n 0 "$(printf "\e[1;32mMultiple network interfaces are found, please select one for local network:\e[0m")"
  assert_line -n 1 '  1) en0: 192.168.10.100'
  assert_line -n 2 '  2) vboxnet0: 10.10.10.1'
  assert_line -n 3 "$(printf "\e[1;36m\e[1A\e[2K1-2 ? \e[0m")"

  unalias ifconfig
}

@test 'local_ip - N IPv4 (output)' {
  local ip

  shopt -s expand_aliases
  alias ifconfig="cat ${BATS_TEST_DIRNAME}/fixture/ifconfigN.txt" # stub `ifconfig`
  printf "2\n" > input.txt
  local_ip ip < input.txt
  assert_equal "${ip}" '10.10.10.1'

  unalias ifconfig
}

@test 'local_ip - success' {
  local ip

  shopt -s expand_aliases
  alias ifconfig="cat ${BATS_TEST_DIRNAME}/fixture/ifconfig1.txt" # stub `ifconfig`
  run local_ip ip
  assert_success
  assert_output ''

  unalias ifconfig
}

@test 'local_ip - no outputs' {
  run local_ip
  assert_failure ${LIB_BASH_ERROR_NO_OUTPUT}
}

@test 'local_ip - command not found' {
  local ip

  shopt -s expand_aliases
  alias ifconfig="some_command" # mimic command not found
  run local_ip ip
  assert_failure ${LIB_BASH_COMMAND_NOT_FOUND}

  unalias ifconfig
}
