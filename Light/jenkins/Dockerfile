FROM jenkins/jenkins
MAINTAINER Teodoro Hochfärber
USER root
RUN curl -fsSL get.docker.com -o get-docker.sh
RUN sh get-docker.sh
USER ${user}
