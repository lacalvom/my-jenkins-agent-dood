# my-jenkins-agent-dood
Container image created to be used as a Jenkins agent in a Jenkins CI/CD server

***my-jenkins-agent-dood*** is a container image created to be used as a ***Jenkins agent*** on a ***CI/CD*** server based on the image: ***jenkins/ssh-agent:4.13.0-jdk11*** which already has the **JDK11** of **Java** installed, and to which some more tools have been added, necessary in this use case in particular.

In this image, **Maven**, **Google Cloud SDK**, **Podman** and **Docker CLI** have been additionally installed, in order to build container images and publish them.

The ***Docker outside of Docker*** technique has been used, which consists of mapping the socket file of the daemon that is running on our Docker server ***/var/run/docker.sock*** as a volume,  and thus be able to access the resources of the ***Docker Host***.

**NOTE:** Depending on the environment, this can be seen as a security vulnerability, but if used judiciously in environments where it is applied it can be very useful and easier to use than other techniques. It is not usually advisable in productive environments and/or exposed to the Internet.

An important detail is that when using this technique you have to match the **GID** of the existing ***docker*** group on the ***Docker Host*** with the **GID** of the same existing group in the container.

This is accomplished by getting the **GID** of the existing ***docker*** group on the ***Docker Host*** prior to building the container image and passing it as an argument in its build.

To get the **GID** of the existing ***docker*** group on the ***Docker Host***:
```bash
DOCKER_GID=$(getent group docker | cut -d: -f3)
```

To pass it as an argument to build the container image, assuming we run the command in the same directory where the ***Dockerfile*** is:
```bash
docker build --build-arg DOCKER_GID=$DOCKER_GID -t my-jenkins-agent-dood:latest .
```

Last but not least is the fact that for this to work properly, you have to run the container in privileged mode and map ***/var/run/docker.sock*** as a volume.

To lift a container and test it:
```bash
docker run --rm -it --name myagent --privileged -v /var/run/docker.sock:/var/run/docker.sock my-jenkins-agent-dood:latest bash
```
To make things easier, there is a ***Makefile*** with all these tasks defined with which you can create a container image, test it and publish it to ***Docker Hub*** if necessary.

For details about container creation check out the ***Dockerfile***.
