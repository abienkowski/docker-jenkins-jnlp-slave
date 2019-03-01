FROM jenkins/slave
MAINTAINER Adrian Bienkowski

# -- copy start up script
COPY jenkins-slave /usr/local/bin/jenkins-slave

USER root

# -- install build essentials and tools
RUN apt update -qqy \
 && apt -qqy install \
    build-essential \
    ca-certificates \
    clang \
    curl \
    git \
    jq \
    less \
    libxml2-utils \
    python \
    python-pip \
    rsync \
    netcat \
    tzdata \
 && rm -rf /var/lib/apt/lists/*

# -- install OpenStack cli tools
RUN pip install \
    python-openstackclient \
    python-heatclient

USER jenkins

# -- set entrypoint for the container
ENTRYPOINT ["/usr/local/bin/jenkins-slave"]
