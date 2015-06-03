FROM debian:jessie
MAINTAINER Matt Bentley <mbentley@mbentley.net>

RUN (apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y curl wget openjdk-7-jre-headless git-core mercurial &&\ 
  wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add - &&\
  echo "deb http://pkg.jenkins-ci.org/debian binary/" > /etc/apt/sources.list.d/jenkins.list &&\
  apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y jenkins &&\
  wget --output-document=/usr/local/bin/docker https://get.docker.com/builds/Linux/x86_64/docker-latest &&\
  chmod +x /usr/local/bin/docker &&\
  mkdir -p /var/lib/jenkins/plugins)

ENV JENKINS_HOME /var/lib/jenkins
ADD plugins/ $JENKINS_HOME/plugins/

RUN (userdel jenkins &&\
  groupadd -g 510 jenkins &&\
  useradd -u 510 -g 510 -d /var/lib/jenkins jenkins &&\
  chown -R jenkins:jenkins /var/lib/jenkins)

USER jenkins
VOLUME /var/lib/jenkins
EXPOSE 8080
CMD ["java","-jar","/usr/share/jenkins/jenkins.war"]
