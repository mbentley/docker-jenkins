FROM debian:sid
MAINTAINER Matt Bentley <mbentley@mbentley.net>

ENV DOCKER_VERSION=17.06.0-ce

RUN (apt-get update && apt-get install -y curl wget openjdk-8-jre-headless git-core gnupg mercurial sudo &&\
  wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add - &&\
  echo "deb http://pkg.jenkins-ci.org/debian binary/" > /etc/apt/sources.list.d/jenkins.list &&\
  apt-get update && apt-get install -y jenkins &&\
  wget --output-document=/tmp/docker-${DOCKER_VERSION}.tgz "https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz" &&\
  cd /tmp  &&\
  tar -vxzf docker-${DOCKER_VERSION}.tgz &&\
  mv /tmp/docker/docker /usr/local/bin/docker &&\
  chmod +x /usr/local/bin/docker &&\
  rm -rf /tmp/docker /tmp/docker-${DOCKER_VERSION}.tgz &&\
  mkdir -p /var/lib/jenkins/plugins)

ENV JENKINS_HOME /var/lib/jenkins
ADD plugins/ $JENKINS_HOME/plugins/

RUN (userdel jenkins &&\
  groupadd -g 510 jenkins &&\
  groupadd -g 998 docker &&\
  useradd -u 510 -g 510 -G docker -d /var/lib/jenkins jenkins &&\
  chown -R jenkins:jenkins /var/lib/jenkins)

RUN (echo 'jenkins            ALL = (ALL) NOPASSWD: ALL' > /etc/sudoers.d/jenkinsnosudo &&\
  chmod 0440 /etc/sudoers.d/jenkinsnosudo)

USER jenkins
VOLUME /var/lib/jenkins
EXPOSE 8080
CMD ["java","-jar","/usr/share/jenkins/jenkins.war"]
