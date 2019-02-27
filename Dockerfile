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
    openssh-client \
    openssl \
    netcat \
    python \
    rsync \
    tzdata \
    dnsutils \
 && rm -rf /var/lib/apt/lists/*

RUN apt update -qqy \
 && apt -qqy install \
    python-pip
 && rm -rf /var/lib/apt/lists/*

RUN pip install \
    python-openstackclient \
    python-heatclient

RUN gem install --no-ri --no-rdoc \
    rake \
    bundler \
    rspec \
    rubocop

USER jenkins

# -- set entrypoint for the container
ENTRYPOINT ["/usr/local/bin/jenkins-slave"]
