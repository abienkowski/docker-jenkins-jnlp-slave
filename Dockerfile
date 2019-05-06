FROM jenkins/slave
MAINTAINER Adrian Bienkowski

# -- copy start up script
COPY jenkins-slave /usr/local/bin/jenkins-slave

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

# -- install jmeter tools
ARG jmeter_ver=5.1.1
RUN wget http://www.us.apache.org/dist/jmeter/binaries/apache-jmeter-${jmeter_ver}.tgz \
 && echo Insalling JMeter version ${jmeter_ver} .. \
 && tar -xzf apache-jmeter-${jmeter_ver}.tgz \
 && echo Successfully unzipped \
 && rm apache-jmeter-${jmeter_ver}.tgz \
 && echo Successfully removed tgz \
 && mkdir -p /opt/jmeter \
 && mv apache-jmeter-${jmeter_ver} jmeter \
 && mv jmeter /opt \
 && wget --content-disposition  https://jmeter-plugins.org/get/ \
 && mv jmeter-plugins-manager*.jar /opt/jmeter/lib/ext/ \
 && echo Successfully moved plugins-manager \
 # https://jmeter-plugins.org/wiki/PluginsManagerAutomated/ -
 && wget --content-disposition  http://search.maven.org/remotecontent?filepath=kg/apc/cmdrunner/2.2/cmdrunner-2.2.jar \
 && echo Successfully downloaded cmdrunner \
 && mv cmdrunner-2.2.jar /opt/jmeter/lib/ \
 && echo Successfully moved cmdrunner to lib directory \
 && echo 1- Successfully installed the latest jmeter and plugins-manager \
 && cd /opt/jmeter/bin \
 && mgr=$(find /opt/jmeter/lib/ext/jmeter-plugins-manager* -printf "%f\n") \
 && java -cp /opt/jmeter/lib/ext/${mgr} org.jmeterplugins.repository.PluginManagerCMDInstaller \
 && echo 2- Getting the list of jmeter plugins from https://jmeter-plugins.org/repo/ \
 && echo This may take a moment.... \
 && jmpl=$(curl -s https://jmeter-plugins.org/repo/ | jq '.[] | select(."id" | contains("jpgc-sense","jpgc-webdriver","jpgc-standard","jpgc-graphs-basic","jpgc-graphs-additional","jpgc-perfmon","jpgc-casutg"))' | jq ."id" | tr '\n' ',' | sed 's/"//g' | sed s'/.$//') \
 && echo ${jmpl} \
 && sh PluginsManagerCMD.sh install ${jmpl} \
 && echo 3- Successfully installed the jmeter plugins

ENV PATH /opt/jmeter/bin:$PATH
ENV JMETER_HOME /opt/jmeter/bin

# -- switch back to jenkins user for service
USER jenkins

# -- set entrypoint for the container
ENTRYPOINT ["/usr/local/bin/jenkins-slave"]
