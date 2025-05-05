# mbentley/jenkins

docker image for jenkins

To pull this image:
`docker pull mbentley/jenkins`

## Jenkins Controller

Example usage:

```bash
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

```bash
docker run -d \
  --name jenkins-agent \
  -e JENKINS_URL="https://jenkins.example.com/" \
  -e JENKINS_SECRET="myjenkinsnodesecretgoeshere" \
  -e WEBSOCKET=true \
  -e NODE_NAME="agent1" \
  -e MAX_MEMORY="4g" \
  -e JAVA_OPTS="-XX:+UseG1GC -XX:+UseStringDeduplication -XX:+ParallelRefProcEnabled -XX:+DisableExplicitGC -XX:+UnlockDiagnosticVMOptions -XX:+UnlockExperimentalVMOptions -verbose:gc -Xlog:gc" \
   mbentley/jenkins:agent
```

## Additional Options

* `CUSTOM_OPTS` - append additional options instead of completely overriding `JAVA_OPTS`
* `TUNNEL` - set the `-tunnel` value for a Jenkins agent if using the TCP port
