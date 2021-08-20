#!/bin/sh

# variables that are inherited from the Dockerfile or passed at runtime
JAVA_OPTS="${JAVA_OPTS:-}"
MAX_MEMORY="${MAX_MEMORY:-}"

case $1 in
  jenkins)
    # shellcheck disable=SC2086
    exec tini -- java "-Xmx${MAX_MEMORY}" "-Xms${MAX_MEMORY}" ${JAVA_OPTS} -jar /usr/share/jenkins/jenkins.war
    ;;
  *)
    exec "${@}"
    ;;
esac
