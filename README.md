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
  -e JAVA_OPTS="-XX:+UseG1GC -XX:MaxRAMPercentage=50.0 -XX:InitialRAMPercentage=25.0 -XX:+DisableExplicitGC -Xlog:gc" \
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
  -e MAX_MEMORY="2g" \
  -e JAVA_OPTS="-XX:+UseG1GC -XX:+DisableExplicitGC -Xlog:gc" \
   mbentley/jenkins:agent
```

## Additional Options

* `MAX_MEMORY` - optional fixed heap size (sets `-Xmx` and `-Xms`); if unset on the controller, the heap is sized by `MaxRAMPercentage`/`InitialRAMPercentage` in `JAVA_OPTS` (the agent image defaults to `2g`)
* `CUSTOM_OPTS` - append additional options instead of completely overriding `JAVA_OPTS`
* `TUNNEL` - set the `-tunnel` value for a Jenkins agent if using the TCP port
