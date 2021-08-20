FROM debian:bullseye
MAINTAINER Matt Bentley <mbentley@mbentley.net>

ARG JENKINS_VER
ARG DOCKER_VERSION=20.10.8
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update &&\
  apt-get install -y curl git-core gnupg jq lynx mercurial openjdk-11-jre-headless sudo tini w3m wget &&\
  wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add - &&\
  echo "deb https://pkg.jenkins.io/debian-stable binary/" > /etc/apt/sources.list.d/jenkins.list &&\
  apt-get update &&\
  apt-get install -y jenkins &&\
  wget --output-document=/tmp/docker-${DOCKER_VERSION}.tgz "https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz" &&\
  cd /tmp  &&\
  tar -vxzf docker-${DOCKER_VERSION}.tgz &&\
  mv /tmp/docker/docker /usr/local/bin/docker &&\
  chmod +x /usr/local/bin/docker &&\
  rm -rf /tmp/docker /tmp/docker-${DOCKER_VERSION}.tgz /var/lib/apt/lists/* &&\
  mkdir -p /var/lib/jenkins/plugins &&\
  chown -R 510:510 /var/lib/jenkins &&\
  userdel jenkins &&\
  groupadd -g 510 jenkins &&\
  groupadd -g 998 docker &&\
  groupadd -g 999 docker2 &&\
  useradd -u 510 -g 510 -G docker,docker2 -d /var/lib/jenkins jenkins &&\
  echo 'jenkins            ALL = (ALL) NOPASSWD: ALL' > /etc/sudoers.d/jenkinsnosudo &&\
  chmod 0440 /etc/sudoers.d/jenkinsnosudo

# JAVA_OPTS best practices come from https://support.cloudbees.com/hc/en-us/articles/222446987-Prepare-Jenkins-for-Support
ENV JENKINS_HOME=/var/lib/jenkins \
  JAVA_OPTS="-Xmx8g -Xms8g -XX:+UseG1GC -XX:+UseStringDeduplication -XX:+ParallelRefProcEnabled -XX:+DisableExplicitGC -XX:+UnlockDiagnosticVMOptions -XX:+UnlockExperimentalVMOptions -verbose:gc -Xlog:gc*"

COPY entrypoint.sh /entrypoint.sh

USER jenkins
VOLUME /var/lib/jenkins
EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
CMD ["jenkins"]
