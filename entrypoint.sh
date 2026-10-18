#!/bin/sh

# variables that are inherited from the Dockerfile or passed at runtime
JAVA_OPTS="${JAVA_OPTS:-}"
CUSTOM_OPTS="${CUSTOM_OPTS:-}"
JENKINS_OPTS="${JENKINS_OPTS:-}"
MAX_MEMORY="${MAX_MEMORY:-}"
HEAP_OPTS=""
JENKINS_URL="${JENKINS_URL:-}"
NODE_NAME="${NODE_NAME:-}"
JENKINS_SECRET="${JENKINS_SECRET:-}"
JENKINS_JAR="${JENKINS_JAR:-/usr/share/java/jenkins.war}"
AGENT_JAR="${AGENT_JAR:-/usr/share/jenkins/agent.jar}"
TUNNEL="${TUNNEL:-}"
WEBSOCKET="${WEBSOCKET:-false}"

if [ -n "${TUNNEL}" ]
then
  # agent tunnel provided; set string
  TUNNEL="-tunnel ${TUNNEL}"
fi

if [ "${WEBSOCKET}" = "true" ]
then
  # agent websocket set to true; add argument
  WEBSOCKET="-webSocket -noReconnect"
else
  # websocket isn't true; clear variable
  WEBSOCKET=""
fi

# only set a fixed heap if MAX_MEMORY is provided; otherwise the JVM uses the RAM percentage options in JAVA_OPTS
if [ -n "${MAX_MEMORY}" ]
then
  HEAP_OPTS="-Xmx${MAX_MEMORY} -Xms${MAX_MEMORY}"
fi

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
    echo "  tini -- java ${HEAP_OPTS} ${JAVA_OPTS} ${CUSTOM_OPTS} -jar \"${AGENT_JAR}\" ${JENKINS_OPTS} -url \"${JENKINS_URL}\" -name \"${NODE_NAME}\" -secret \"********\" ${WEBSOCKET} ${TUNNEL} -workDir \"/var/lib/jenkins\""
    echo

    # shellcheck disable=SC2086
    exec tini -- java ${HEAP_OPTS} ${JAVA_OPTS} ${CUSTOM_OPTS} -jar "${AGENT_JAR}" ${JENKINS_OPTS} -url "${JENKINS_URL}" -name "${NODE_NAME}" -secret "${JENKINS_SECRET}" ${WEBSOCKET} ${TUNNEL} -workDir "/var/lib/jenkins"
    ;;
  jenkins)
    # output info
    echo "INFO: starting with:"
    echo "  tini -- java ${HEAP_OPTS} ${JAVA_OPTS} ${CUSTOM_OPTS} -jar \"${JENKINS_JAR}\" ${JENKINS_OPTS}"
    echo

    # shellcheck disable=SC2086
    exec tini -- java ${HEAP_OPTS} ${JAVA_OPTS} ${CUSTOM_OPTS} -jar "${JENKINS_JAR}" ${JENKINS_OPTS}
    ;;
  *)
    exec "${@}"
    ;;
esac
