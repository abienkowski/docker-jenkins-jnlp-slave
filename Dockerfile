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
    openjdk-8-jdk \
    python \
    rsync \
    tzdata \
	unzip \
 && rm -rf /var/lib/apt/lists/*

# -- Install security tools
ENV SPOTBUGS_VERSION=3.1.11
ENV DEPCHECK_VERSION=4.0.2
ENV MAVEN_VERSION=3.5.4
 
RUN mkdir -p /opt/security-tools
WORKDIR /opt/security-tools

# -- Get Maven
RUN curl --create-dirs -sSLo /opt/security-tools/apache-maven-${MAVEN_VERSION}.tar.gz http://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz

# -- Install Maven
RUN tar xzf /opt/security-tools/apache-maven-${MAVEN_VERSION}.tar.gz
RUN ln -s /opt/security-tools/apache-maven-${MAVEN_VERSION} /opt/maven
RUN ln -s /opt/maven/bin/mvn /usr/local/bin
RUN rm -f /opt/security-tools/apache-maven-${MAVEN_VERSION}.tar.gz
ENV MAVEN_HOME /opt/maven

# -- Install SpotBugs with FindSecBugs plugin
RUN curl --create-dirs -sSLo /opt/security-tools/spotbugs.zip http://central.maven.org/maven2/com/github/spotbugs/spotbugs/${SPOTBUGS_VERSION}/spotbugs-${SPOTBUGS_VERSION}.zip
RUN unzip /opt/security-tools/spotbugs.zip
 
RUN curl --create-dirs -sSLo /opt/security-tools/spotbugs-${SPOTBUGS_VERSION}/plugin/findsecbugs-plugin.jar  http://central.maven.org/maven2/com/h3xstream/findsecbugs/findsecbugs-plugin/1.8.0/findsecbugs-plugin-1.8.0.jar
 
# -- Install OWASP Depdendency check
 
RUN curl --create-dirs -sSLo /opt/security-tools/dependency-check.zip  https://dl.bintray.com/jeremy-long/owasp/dependency-check-${DEPCHECK_VERSION}-release.zip
RUN unzip /opt/security-tools/dependency-check.zip
 
# -- Remove downloaded zip files
RUN rm -f /opt/security-tools/spotbugs.zip  /opt/security-tools/dependency-check.zip


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
 && useradd -u 10000 -m -g jenkins jenkins

RUN chmod -R 777 /opt/security-tools
RUN chown -R jenkins /opt/security-tools
RUN ls -la /opt/security-tools

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
