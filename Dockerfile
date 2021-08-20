FROM debian:bullseye
MAINTAINER Matt Bentley <mbentley@mbentley.net>

ARG JENKINS_VER
ARG DEBIAN_FRONTEND=noninteractive

# install jenkins
RUN apt-get update &&\
  apt-get install -y curl git-core gnupg jq lynx mercurial openjdk-11-jre-headless sudo tini w3m wget &&\
  wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add - &&\
  echo "deb https://pkg.jenkins.io/debian-stable binary/" > /etc/apt/sources.list.d/jenkins.list &&\
  apt-get update &&\
  apt-get install -y jenkins &&\
  mkdir -p /var/lib/jenkins/plugins &&\
  chown -R 510:510 /var/lib/jenkins &&\
  userdel jenkins &&\
  groupadd -g 510 jenkins &&\
  groupadd -g 998 docker &&\
  groupadd -g 999 docker2 &&\
  useradd -u 510 -g 510 -G docker,docker2 -d /var/lib/jenkins jenkins &&\
  echo 'jenkins            ALL = (ALL) NOPASSWD: ALL' > /etc/sudoers.d/jenkinsnosudo &&\
  chmod 0440 /etc/sudoers.d/jenkinsnosudo &&\
  rm -rf /var/lib/apt/lists/*

# install docker cli from the docker repos
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - &&\
  echo "deb [arch=amd64] https://download.docker.com/linux/debian bullseye stable" > /etc/apt/sources.list.d/docker.list &&\
  apt-get update &&\
  apt-get install -y docker-ce-cli &&\
  rm -rf /var/lib/apt/lists/*

# JAVA_OPTS best practices come from https://support.cloudbees.com/hc/en-us/articles/222446987-Prepare-Jenkins-for-Support
ENV JENKINS_HOME=/var/lib/jenkins \
  JAVA_OPTS="-XX:+UseG1GC -XX:+UseStringDeduplication -XX:+ParallelRefProcEnabled -XX:+DisableExplicitGC -XX:+UnlockDiagnosticVMOptions -XX:+UnlockExperimentalVMOptions -verbose:gc -Xlog:gc" \
  MAX_MEMORY="4g"

COPY entrypoint.sh /entrypoint.sh

USER jenkins
VOLUME /var/lib/jenkins
EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
CMD ["jenkins"]
