# rebased/repackaged base image that only updates existing packages
FROM mbentley/debian:bookworm
LABEL maintainer="Matt Bentley <mbentley@mbentley.net>"

ARG JENKINS_VER
ARG DEBIAN_FRONTEND=noninteractive

# install jenkins
RUN apt-get update &&\
  apt-get install --no-install-recommends -y bzip2 ca-certificates curl fontconfig git-core gnupg jq less lynx openjdk-17-jre-headless openssh-client parallel patch psmisc sudo tini w3m wget xmlstarlet &&\
  wget -q -O - "https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key" | gpg --dearmor -o /etc/apt/keyrings/jenkins.gpg &&\
  echo "deb [arch=\"$(dpkg --print-architecture)\" signed-by=/etc/apt/keyrings/jenkins.gpg] http://pkg.jenkins.io/debian-stable binary/" > /etc/apt/sources.list.d/jenkins.list &&\
  apt-get update &&\
  apt-get install --no-install-recommends -y jenkins &&\
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
RUN wget -q -O - https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg &&\
  echo "deb [arch=\"$(dpkg --print-architecture)\" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian bullseye stable" > /etc/apt/sources.list.d/docker.list &&\
  apt-get update &&\
  apt-get install -y --no-install-recommends docker-ce-cli &&\
  rm -rf /var/lib/apt/lists/*

ARG RUSH_VER

# install rush
RUN cd /tmp &&\
  wget -q -O rush_linux_amd64.tar.gz "https://github.com/shenwei356/rush/releases/download/${RUSH_VER}/rush_linux_amd64.tar.gz" &&\
  tar xvf rush_linux_amd64.tar.gz &&\
  rm rush_linux_amd64.tar.gz &&\
  chmod +x rush &&\
  mv rush /usr/local/bin/rush

# copy in entrypoint
COPY entrypoint.sh /entrypoint.sh

# drop from root to jenkins
USER jenkins

# JAVA_OPTS best practices come from https://support.cloudbees.com/hc/en-us/articles/222446987-Prepare-Jenkins-for-Support
ENV JENKINS_HOME=/var/lib/jenkins \
  JAVA_OPTS="-XX:+UseG1GC -XX:+UseStringDeduplication -XX:+ParallelRefProcEnabled -XX:+DisableExplicitGC -XX:+UnlockDiagnosticVMOptions -XX:+UseContainerSupport -Dorg.jenkinsci.plugins.pipeline.modeldefinition.parser.RuntimeASTTransformer.SCRIPT_SPLITTING_TRANSFORMATION=true" \
  MAX_MEMORY="4g"

VOLUME /var/lib/jenkins
EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
CMD ["jenkins"]
