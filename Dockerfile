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

# -- Install security tools in TOOLS_DIR
ENV SPOTBUGS_VERSION=3.1.11
ENV DEPCHECK_VERSION=4.0.2
ENV ZAP_VERSION=2.7.0
ENV ZAP_VERSION_F=2_7_0
ENV TOOLS_DIR=/opt/security-tools
 
RUN mkdir -p $TOOLS_DIR

# -- Install SpotBugs with FindSecBugs plugin
RUN curl -sSL http://central.maven.org/maven2/com/github/spotbugs/spotbugs/${SPOTBUGS_VERSION}/spotbugs-${SPOTBUGS_VERSION}.tgz | tar -zxf - -C $TOOLS_DIR \
 && curl --create-dirs -sSLo /opt/security-tools/spotbugs-${SPOTBUGS_VERSION}/plugin/findsecbugs-plugin.jar http://central.maven.org/maven2/com/h3xstream/findsecbugs/findsecbugs-plugin/1.8.0/findsecbugs-plugin-1.8.0.jar
 
# -- Install OWASP Depdendency check
RUN cd $TOOLS_DIR \
 && curl -sSLO https://dl.bintray.com/jeremy-long/owasp/dependency-check-${DEPCHECK_VERSION}-release.zip \
 && unzip dependency-check-${DEPCHECK_VERSION}-release.zip \
 && rm -f dependency-check-${DEPCHECK_VERSION}-release.zip
 
 
 # -- Install OWASP ZAP
 RUN cd $TOOLS_DIR \
 && curl -sSLO https://github.com/zaproxy/zaproxy/releases/download/${ZAP_VERSION}/ZAP_${ZAP_VERSION_F}_unix.sh \
 && sh ZAP_${ZAP_VERSION_F}_unix.sh \
 && zaproxy 

# -- as jenkins user
USER jenkins

# -- set entrypoint for the container
ENTRYPOINT ["/usr/local/bin/jenkins-slave"]
