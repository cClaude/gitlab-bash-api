#!/bin/bash -e

TESTS_HOME=$(dirname "$(realpath "$0")")
declare -r TESTS_HOME=${TESTS_HOME}

function run_all_tests {
  local test_script

  find "${TESTS_HOME}" -maxdepth 1 -name "test-*.sh" | while read -r line; do
    test_script=$(realpath --relative-to=. "${line}")

    echo '# running # #######################################################################################'
    echo "# running # ${test_script}"
    echo '# running # #######################################################################################'
    bash "${test_script}"
  done
}

run_all_tests
