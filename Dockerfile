FROM jenkins/jnlp-slave
MAINTAINER Adrian Bienkowski

# -- as root
USER root

# -- install build essentials and tools
RUN apt-get update -qqy \
 && apt-get -qqy --no-install-recommends install \
    build-essential \
    ca-certificates \
    clang \
    curl openssh-client openssl \
    git \
    jq \
    less \
    libxml2-utils \
    openjdk-8-jre-headless \
    python \
    rsync \
    tzdata \
 && rm -rf /var/lib/apt/lists/*

# -- as jenkins user
USER jenkins
