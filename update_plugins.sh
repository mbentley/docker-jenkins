#!/bin/bash

set -e

SCRIPT_HOME="$( cd "$( dirname "$0" )" && pwd )"

URL="http://updates.jenkins-ci.org/latest/"

cd "$SCRIPT_HOME/plugins"

plugins="bouncycastle-api build-blocker-plugin cobertura copy-to-slave credentials display-url-api git git-client git-parameter github github-api greenballs instant-messaging jabber javadoc jquery junit mailer matrix-project maven-plugin mercurial plain-credentials postbuild-task scm-api script-security ssh ssh-agent ssh-credentials structs token-macro workflow-scm-step workflow-step-api"

for i in ${plugins}
do
  wget -nv -N --no-check-certificate "${URL}/${i}.hpi"
done
