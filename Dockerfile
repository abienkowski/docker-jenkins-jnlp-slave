FROM ubuntu:16.04
MAINTAINER Adrian Bienkowski

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
    ruby \
    ruby-dev \
    rsync \
    netcat \
    tzdata \
    dnsutils \
 && apt-get -qqy install python-pip \
 && pip install python-openstackclient \
 && pip install python-heatclient \
 && gem install --no-ri --no-rdoc rake \
 && gem install --no-ri --no-rdoc bundler \
 && gem install --no-ri --no-rdoc rspec \
 && gem install --no-ri --no-rdoc rubocop \
 && rm -rf /var/lib/apt/lists/*

ARG CHEFDK_VERSION=1.6.11
ARG CHEFDK_FILE=chefdk_1.6.11-1_amd64.deb
# -- add chefdk
RUN curl -sSLo /${CHEFDK_FILE} https://packages.chef.io/files/stable/chefdk/${CHEFDK_VERSION}/ubuntu/16.04/${CHEFDK_FILE} \
 && dpkg -i /${CHEFDK_FILE}
# -- add gem dependencies required for deployment
RUN eval $(chef shell-init sh) \
 && gem install --no-ri --no-rdoc chef-provisioning-ssh -v 0.1.0

# -- set agent version an workdir
ARG VERSION=3.14
ARG AGENT_WORKDIR=/home/jenkins/agent

# -- install slave jar
RUN curl --create-dirs -sSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/slave.jar

# -- copy start up script
COPY jenkins-slave /usr/local/bin/jenkins-slave

# -- create jenkins user and home directory
ENV HOME /home/jenkins
RUN groupadd -g 10000 jenkins \
 && useradd -u 10000 -m -g jenkins jenkins \
 && ln -snf /home/jenkins/.chef /var/chef

# -- as jenkins user
USER jenkins
ENV AGENT_WORKDIR=${AGENT_WORKDIR}
RUN mkdir /home/jenkins/.jenkins \
 && mkdir -p /home/jenkins/.ssh \
 && mkdir -p /home/jenkins/.m2 \
 && mkdir -p ${AGENT_WORKDIR}

# -- set working directory for the container
WORKDIR /home/jenkins

# -- set entrypoint for the container
ENTRYPOINT ["/usr/local/bin/jenkins-slave"]
