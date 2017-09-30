#!/bin/bash

declare -r PROJECT_FOLDER=$(dirname $(dirname $(realpath $0)))

declare -r TEST_SSH=${PROJECT_FOLDER}/tests-result/clone-all-on-ssh

rm -rf "${TEST_SSH}"
mkdir -p "${TEST_SSH}"

#bash -ex
${PROJECT_FOLDER}/glCloneAllProjects.sh --ssh --destination "${TEST_SSH}"

declare -r TEST_HTTP=${PROJECT_FOLDER}/tests-result/clone-all-on-http

rm -rf "${TEST_HTTP}"
mkdir -p "${TEST_HTTP}"

#bash -ex
${PROJECT_FOLDER}/glCloneAllProjects.sh --ssh --destination "${TEST_HTTP}"
