FROM jenkins/slave
MAINTAINER Adrian Bienkowski

# -- copy start up script
COPY jenkins-slave /usr/local/bin/jenkins-slave

USER root

# -- install build essentials and tools
RUN apt update -qqy \
 && apt upgrade -qqy \
 && apt -qqy install \
    build-essential \
    ca-certificates \
    clang \
    curl \
    git \
    jq \
    less \
    libxml2-utils \
    openssh-client \
    openssl \
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
RUN chmod -R 777 /opt/security-tools
RUN chown -R jenkins /opt/security-tools
RUN ls -la /opt/security-tools/dependency-check

# -- as jenkins user
USER jenkins

# -- set entrypoint for the container
ENTRYPOINT ["/usr/local/bin/jenkins-slave"]
