FROM debian:sid
MAINTAINER Matt Bentley <mbentley@mbentley.net>

ENV DOCKER_VERSION=18.09.5

RUN (apt-get update && apt-get install -y curl wget openjdk-11-jre-headless git-core gnupg mercurial sudo &&\
  wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add - &&\
  echo "deb https://pkg.jenkins.io/debian-stable binary/" > /etc/apt/sources.list.d/jenkins.list &&\
  apt-get update && apt-get install -y jenkins &&\
  wget --output-document=/tmp/docker-${DOCKER_VERSION}.tgz "https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz" &&\
  cd /tmp  &&\
  tar -vxzf docker-${DOCKER_VERSION}.tgz &&\
  mv /tmp/docker/docker /usr/local/bin/docker &&\
  chmod +x /usr/local/bin/docker &&\
  rm -rf /tmp/docker /tmp/docker-${DOCKER_VERSION}.tgz &&\
  mkdir -p /var/lib/jenkins/plugins &&\
  chown -R 510:510 /var/lib/jenkins)

ENV JENKINS_HOME /var/lib/jenkins

RUN (userdel jenkins &&\
  groupadd -g 510 jenkins &&\
  groupadd -g 998 docker &&\
  groupadd -g 999 docker2 &&\
  useradd -u 510 -g 510 -G docker,docker2 -d /var/lib/jenkins jenkins)

RUN (echo 'jenkins            ALL = (ALL) NOPASSWD: ALL' > /etc/sudoers.d/jenkinsnosudo &&\
  chmod 0440 /etc/sudoers.d/jenkinsnosudo)

USER jenkins
VOLUME /var/lib/jenkins
EXPOSE 8080
CMD ["java","-jar","/usr/share/jenkins/jenkins.war"]
