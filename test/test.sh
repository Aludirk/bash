#!/usr/bin/env bash

pushd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null

bats/bin/bats test
exit_code=${?}

popd &> /dev/null

exit ${exit_code}
