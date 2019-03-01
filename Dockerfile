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
    dnsutils \
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

ARG CHEFDK_VERSION=1.6.11
ARG CHEFDK_FILE=chefdk_1.6.11-1_amd64.deb
# -- add chefdk
RUN curl -sSLo /${CHEFDK_FILE} https://packages.chef.io/files/stable/chefdk/${CHEFDK_VERSION}/ubuntu/16.04/${CHEFDK_FILE} \
 && dpkg -i /${CHEFDK_FILE}

# -- switch back to jenkins user for installing local gems
USER jenkins

# -- add gem dependencies required for deployment
RUN eval $(chef shell-init sh) \
 && gem install --no-ri --no-rdoc chef-provisioning-ssh -v 0.1.0

# -- set entrypoint for the container
ENTRYPOINT ["/usr/local/bin/jenkins-slave"]
