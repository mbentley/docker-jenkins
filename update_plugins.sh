#!/bin/bash

SCRIPT_HOME="$( cd "$( dirname "$0" )" && pwd )"

cd $SCRIPT_HOME/plugins

plugins="build-blocker-plugin cobertura greenballs instant-messaging postbuild-task copy-to-slave credentials ssh-credentials ssh ssh-agent git-client git-parameter git github-api github scm-api mercurial jabber"

for i in ${plugins}
do
  wget -nv -N --no-check-certificate http://ftp-nyc.osuosl.org/pub/jenkins/plugins/${i}/latest/${i}.hpi
done
