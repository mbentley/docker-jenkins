mbentley/jenkins
==================

docker image for jenkins

To pull this image:
`docker pull mbentley/jenkins`

Example usage:
`docker run -p 8080 -d mbentley/jenkins`

Note: Jenkins runs as the user `jenkins` in the container.  The jenkins user uid & gid are `510` in case a volume is used for the data in `/var/lib/jenkins`.
