FROM jenkins/ssh-agent:4.13.0-jdk11

USER root

# Install additional packages
RUN apt-get update && apt-get -y install apt-transport-https ca-certificates curl gnupg2 gnupg-agent software-properties-common wget tree podman

# Download and install docker.
RUN curl -fsSL https://get.docker.com -o get-docker.sh && sh ./get-docker.sh

# Mount docker.sock.
VOLUME [ "/var/run/docker.sock" ]

# Add a jenkins user to the docker group with the same GID as the host's docker group
ARG DOCKER_GID
ENV DOCKER_GID ${DOCKER_GID:-998}
RUN usermod -aG docker jenkins
RUN groupmod -g ${DOCKER_GID} docker

# Install Maven
RUN wget -O apache-maven-3.8.4-bin.tar.gz https://archive.apache.org/dist/maven/maven-3/3.8.4/binaries/apache-maven-3.8.4-bin.tar.gz && \
    tar xzf apache-maven-3.8.4-bin.tar.gz -C /usr/share && \
    mv /usr/share/apache-maven-3.8.4 /usr/share/maven && \
    ln -s /usr/share/maven/bin/mvn /usr/bin/mvn && \
    rm -f apache-maven-3.8.4-bin.tar.gz
  
# Install gcloud SDK
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && \
    apt-get update && \
    apt-get -y install google-cloud-sdk 

# Cleaning up caches
RUN apt-get autoremove && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Add environment variables and new paths for root user
ENV MAVEN_HOME=/usr/share/maven M2_HOME=/usr/share/maven
RUN echo 'export PATH="$PATH::/opt/gcloud/google-cloud-sdk/bin/"' >> /root/.bashrc

# Add environment variables and new paths for jenkins user
USER jenkins
ENV MAVEN_HOME=/usr/share/maven M2_HOME=/usr/share/maven
RUN echo 'export PATH="/opt/java/openjdk/bin:$PATH:/opt/gcloud/google-cloud-sdk/bin"' >> /home/jenkins/.bashrc

# Going back to the root user
USER root