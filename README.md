# mbentley/jenkins

docker image for jenkins

To pull this image:
`docker pull mbentley/jenkins`


## Jenkins Controller

Example usage:

```
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -e MAX_MEMORY="4g" \
  -e JAVA_OPTS="-XX:+UseG1GC -XX:+UseStringDeduplication -XX:+ParallelRefProcEnabled -XX:+DisableExplicitGC -XX:+UnlockDiagnosticVMOptions -XX:+UnlockExperimentalVMOptions -verbose:gc -Xlog:gc" \
   mbentley/jenkins
```

Note: Jenkins runs as the user `jenkins` in the container.  The jenkins user uid & gid are `510` in case a volume is used for the data in `/var/lib/jenkins`.

## Jenkins Agent

Example usage:

```
docker run -d \
  --name jenkins-agent \
  -e JENKINS_URL="https://jenkins.example.com/" \
  -e NODE_NAME="agent1" \
  -e JENKINS_SECRET="myjenkinsnodesecretgoeshere" \
  -e MAX_MEMORY="4g" \
  -e JAVA_OPTS="-XX:+UseG1GC -XX:+UseStringDeduplication -XX:+ParallelRefProcEnabled -XX:+DisableExplicitGC -XX:+UnlockDiagnosticVMOptions -XX:+UnlockExperimentalVMOptions -verbose:gc -Xlog:gc" \
   mbentley/jenkins:agent
```
