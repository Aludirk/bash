#!/usr/bin/env bash

pushd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null
source "../../../command.sh"
popd &> /dev/null

args=("${@}")
get_option "ab[beta]c:d[delta]:e:" args[@] options params
exit_code=${?}
if [[ ${exit_code} -ne 0 ]]; then
  exit ${exit_code}
fi

for option in "${options[@]}"; do
  parse_option "${option}" opt data
  printf "%s\n" "Option:${opt} Data:${data}"
done

for param in "${params[@]}"; do
  printf "%s\n" "Param:${param}"
done
