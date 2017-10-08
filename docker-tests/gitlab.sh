#!/bin/bash

# https://docs.gitlab.com/omnibus/docker/README.html

source "$(dirname $(realpath "$0"))/generated-config-bootstrap/init.sh"

function display_usage {
  echo "Usage: $0
  Start docker
    $0 --start
  Restart docker
    $0 --restart
  Show help
    $0 --help
" >&2
  exit 100
}

function docker_run {
  sudo docker run --detach \
    --hostname "${DOCKER_GITLAB_HTTP_HOST}" \
    --publish 443:443 --publish ${DOCKER_HTTP_PORT}:80 --publish ${DOCKER_SSH_PORT}:22 \
    --name "${DOCKER_NAME}" \
    --restart "${DOCKER_RESTART_MODE}" \
    --volume "${DOCKER_ETC_VOLUME}:/etc/gitlab" \
    --volume "${DOCKER_LOGS_VOLUME}:/var/log/gitlab" \
    --volume "${DOCKER_DATA_VOLUME}:/var/opt/gitlab" \
    "${DOCKER_GITLAB_VERSION}"
  docker_run_rc=$?

  if [ ${docker_run_rc} -ne 0 ]; then
    echo "*** docker run error :  ${docker_run_rc}" >&2
  fi
  if [ ${docker_run_rc} -eq 125 ]; then
    echo 'Already running -> try to restart' >&2

    docker_restart
  fi
}

function docker_restart {
  sudo docker restart "${DOCKER_NAME}"
}

function display_help {
  echo "
To upgrade gitlab or change version (current version '${DOCKER_GITLAB_VERSION}')
or all to have cache all versions locally.
  sudo docker pull gitlab/gitlab-ce:latest
  sudo docker pull gitlab/gitlab-ce:rc
  sudo docker pull gitlab/gitlab-ee:latest
  sudo docker pull gitlab/gitlab-ee:rc

then stop and remove the existing container:
  sudo docker stop "${DOCKER_NAME}"; sudo docker rm "${DOCKER_NAME}"

finally start the container as you did originally.
  $0

To reset everything stop and remove container then
  sudo rm -fr "${DOCKER_ETC_VOLUME}" "${DOCKER_LOGS_VOLUME}" "${DOCKER_DATA_VOLUME}"

and restart the container as you did originally.
  $0
"
}

function main {
  local action_rc=0

  if [ $# -eq 0 ]; then
    display_usage
    action_rc=$?
  fi

  while [[ $# > 0 ]]; do
    param="$1"
    shift

    case "${param}" in
      --restart)
        docker_restart
        action_rc=$?
        ;;
      --start)
        docker_run
        action_rc=$?
        display_help
        ;;
      --help)
        display_help
        display_usage
        action_rc=$?
        ;;
      *)
        # unknown option
        echo "Unknown parameter ${param}" >&2
        display_usage
        action_rc=$?
        ;;
    esac
  done

  exit ${action_rc}
}

main "$@" || exit $?
