#!/bin/sh

# variables that are inherited from the Dockerfile or passed at runtime
JAVA_OPTS="${JAVA_OPTS:-}"
CUSTOM_OPTS="${CUSTOM_OPTS:-}"
JENKINS_OPTS="${JENKINS_OPTS:-}"
MAX_MEMORY="${MAX_MEMORY:-}"
JENKINS_URL="${JENKINS_URL:-}"
NODE_NAME="${NODE_NAME:-}"
JENKINS_SECRET="${JENKINS_SECRET:-}"
JENKINS_JAR="${JENKINS_JAR:-/usr/share/java/jenkins.war}"
AGENT_JAR="${AGENT_JAR:-/usr/share/jenkins/agent.jar}"

# determine if we want to run the jenkins-agent or jenkins
case $1 in
  jenkins-agent)
    # make sure we have all of the required parameters
    if [ -z "${JENKINS_URL}" ] || [ -z "${NODE_NAME}" ] || [ -z "${JENKINS_SECRET}" ]
    then
      echo "ERROR: required environment variable(s) missing: JENKINS_URL, NODE_NAME, and/or JENKINS_SECRET"
      exit 1
    fi

    # output info
    echo "INFO: starting with:"
    echo "  tini -- java \"-Xmx${MAX_MEMORY}\" \"-Xms${MAX_MEMORY}\" ${JAVA_OPTS} ${CUSTOM_OPTS} -jar \"${AGENT_JAR}\" -jnlpUrl \"${JENKINS_URL}computer/${NODE_NAME}/jenkins-agent.jnlp\" -secret \"${JENKINS_SECRET}\" -workDir \"/var/lib/jenkins\""
    echo

    # shellcheck disable=SC2086
    exec tini -- java "-Xmx${MAX_MEMORY}" "-Xms${MAX_MEMORY}" ${JAVA_OPTS} ${CUSTOM_OPTS} -jar "${AGENT_JAR}" -jnlpUrl "${JENKINS_URL}computer/${NODE_NAME}/jenkins-agent.jnlp" -secret "${JENKINS_SECRET}" -workDir "/var/lib/jenkins"
    ;;
  jenkins)
    # output info
    echo "INFO: starting with:"
    echo "  tini -- java \"-Xmx${MAX_MEMORY}\" \"-Xms${MAX_MEMORY}\" ${JAVA_OPTS} ${CUSTOM_OPTS} -jar \"${JENKINS_JAR}\""
    echo

    # shellcheck disable=SC2086
    exec tini -- java "-Xmx${MAX_MEMORY}" "-Xms${MAX_MEMORY}" ${JAVA_OPTS} ${CUSTOM_OPTS} -jar "${JENKINS_JAR}"
    ;;
  *)
    exec "${@}"
    ;;
esac
