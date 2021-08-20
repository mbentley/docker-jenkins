#!/bin/sh

JAVA_OPTS="${JAVA_OPTS:-}"

case $1 in
  jenkins)
    exec tini -- java ${JAVA_OPTS} -jar /usr/share/jenkins/jenkins.war
    ;;
  *)
    exec "${@}"
    ;;
esac
