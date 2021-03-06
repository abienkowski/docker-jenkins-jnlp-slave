FROM jenkins/jnlp-slave
MAINTAINER Adrian Bienkowski

# NOTE: this is now part of the parent image
# -- copy start up script
#COPY jenkins-slave /usr/local/bin/jenkins-slave

USER root

# -- install build essentials and tools
RUN apt update -qqy \
 && apt-get upgrade -qqy \
 && apt-get -qqy install \
    build-essential \
    ca-certificates \
    curl \
    git \
    jq \
    openssh-client \
    openssl \
    netcat \
    python \
    rsync \
    ruby ruby-dev \
 && rm -rf /var/lib/apt/lists/*

# -- install gems used for client testing
RUN gem install sass \
 && gem install compass

# -- switch back to jenkins user for service
USER jenkins
