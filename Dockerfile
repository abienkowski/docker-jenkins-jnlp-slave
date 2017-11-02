FROM ubuntu:14.04
MAINTAINER Adrian Bienkowski

COPY jenkins-slave /usr/local/bin/jenkins-slave

ENTRYPOINT ["jenkins-slave"]
