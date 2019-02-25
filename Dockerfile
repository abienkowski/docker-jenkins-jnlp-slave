FROM jenkins/slave
MAINTAINER Adrian Bienkowski

# -- copy start up script
COPY jenkins-slave /usr/local/bin/jenkins-slave

USER root

# -- install build essentials and tools
RUN apt-get update -qqy \
 && apt-get -qqy install \
    build-essential \
    ca-certificates \
    curl \
    git \
    jq \
    openssh-client \
    openssl \
    python \
    rsync \
 && rm -rf /var/lib/apt/lists/*

USER jenkins

# -- set entrypoint for the container
ENTRYPOINT ["/usr/local/bin/jenkins-slave"]
