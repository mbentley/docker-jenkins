FROM debian:jessie
MAINTAINER Matt Bentley <mbentley@mbentley.net>
RUN (echo "deb http://http.debian.net/debian/ jessie main contrib non-free" > /etc/apt/sources.list && echo "deb http://http.debian.net/debian/ jessie-updates main contrib non-free" >> /etc/apt/sources.list && echo "deb http://security.debian.org/ jessie/updates main contrib non-free" >> /etc/apt/sources.list)
RUN apt-get update

RUN (DEBIAN_FRONTEND=noninteractive apt-get install -y curl wget openjdk-7-jre-headless git-core mercurial libpcre3-dev build-essential libssl-dev libexpat-dev libpam-dev &&\
	wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add - &&\
	echo "deb http://pkg.jenkins-ci.org/debian binary/" > /etc/apt/sources.list.d/jenkins.list &&\
	apt-get update &&\
	DEBIAN_FRONTEND=noninteractive RUNLEVEL=1 apt-get install -y jenkins &&\
	wget --output-document=/usr/local/bin/docker https://get.docker.io/builds/Linux/x86_64/docker-latest && chmod +x /usr/local/bin/docker &&\
	mkdir -p /var/lib/jenkins/plugins)

ADD plugins/ /var/lib/jenkins/plugins/
ENV JENKINS_HOME /var/lib/jenkins

VOLUME /var/lib/jenkins
EXPOSE 8080
CMD ["java","-jar","/usr/share/jenkins/jenkins.war"]
