FROM debian:sid
MAINTAINER Matt Bentley <mbentley@mbentley.net>

RUN (apt-get update && apt-get install -y curl wget openjdk-8-jre-headless git-core gnupg mercurial &&\
  wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add - &&\
  echo "deb http://pkg.jenkins-ci.org/debian binary/" > /etc/apt/sources.list.d/jenkins.list &&\
  apt-get update && apt-get install -y jenkins &&\
  wget --output-document=/tmp/docker-latest.tgz "https://get.docker.com/builds/Linux/x86_64/docker-latest.tgz" &&\
  cd /tmp &&\
  tar -vxzf docker-latest.tgz &&\
  mv /tmp/docker/docker /usr/local/bin/docker &&\
  chmod +x /usr/local/bin/docker &&\
  rm -rf /tmp/docker /tmp/docker-latest.tgz &&\
  mkdir -p /var/lib/jenkins/plugins)

ENV JENKINS_HOME /var/lib/jenkins
ADD plugins/ $JENKINS_HOME/plugins/

RUN (userdel jenkins &&\
  groupadd -g 510 jenkins &&\
  groupadd -g 998 docker &&\
  useradd -u 510 -g 510 -G docker -d /var/lib/jenkins jenkins &&\
  chown -R jenkins:jenkins /var/lib/jenkins)

USER jenkins
VOLUME /var/lib/jenkins
EXPOSE 8080
CMD ["java","-jar","/usr/share/jenkins/jenkins.war"]
