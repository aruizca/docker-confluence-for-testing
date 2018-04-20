FROM ubuntu:xenial
MAINTAINER @aruizca - Angel Ruiz

ENV RUN_USER            daemon
ENV RUN_GROUP           daemon

# https://confluence.atlassian.com/doc/confluence-home-and-other-important-directories-590259707.html
ENV CONFLUENCE_HOME          /var/atlassian/application-data/confluence
ENV CONFLUENCE_INSTALL_DIR   /opt/atlassian/confluence

#VOLUME ["${CONFLUENCE_HOME}"]

# Expose HTTP and Synchrony ports
EXPOSE 8090
EXPOSE 8091

#RUN apk update -qq \
#    && update-ca-certificates \
#    && apk add ca-certificates wget curl openssh bash procps openssl perl ttf-dejavu tini libc6-compat jq \
#    && rm -rf /var/lib/{apt,dpkg,cache,log}/ /tmp/* /var/tmp/*
RUN apt-get update && \
    apt-get install -yq wget curl  jq

WORKDIR /root

# Install Jabba JDK Manager
RUN curl -sL https://github.com/shyiko/jabba/raw/master/install.sh | bash && . ~/.jabba/jabba.sh && \
    ln -sf ~/.jabba/bin/jabba /usr/local/bin && \
    chmod -R a+x ~/.jabba/bin/jabba && \
# Install JDK 8
    wget -O jdk-8u144-linux-x64.tar.gz https://www.dropbox.com/s/4aeeivy5zzukxp3/jdk-8u144-linux-x64.tar.gz && \
    jabba install 1.8.144=tgz+file:///root/jdk-8u144-linux-x64.tar.gz && \
    rm jdk-8u144-linux-x64.tar.gz && \
    PATH=/root/.jabba/jdk/1.8.144:$PATH
ENV JAVA_HOME /root/.jabba/jdk/1.8.144

ARG CONFLUENCE_VERSION=6.8.1
ARG DOWNLOAD_URL=http://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-${CONFLUENCE_VERSION}.tar.gz

WORKDIR $CONFLUENCE_HOME

COPY entrypoint.sh              /entrypoint.sh

#COPY . /tmp

RUN mkdir -p                             ${CONFLUENCE_INSTALL_DIR} \
    && curl -L --silent                  ${DOWNLOAD_URL} | tar -xz --strip-components=1 -C "$CONFLUENCE_INSTALL_DIR" \
    && chown -R ${RUN_USER}:${RUN_GROUP} ${CONFLUENCE_INSTALL_DIR}/ \
    && sed -i -e 's/-Xms\([0-9]\+[kmg]\) -Xmx\([0-9]\+[kmg]\)/-Xms\${JVM_MINIMUM_MEMORY:=\1} -Xmx\${JVM_MAXIMUM_MEMORY:=\2} \${JVM_SUPPORT_RECOMMENDED_ARGS} -Dconfluence.home=\${CONFLUENCE_HOME}/g' ${CONFLUENCE_INSTALL_DIR}/bin/setenv.sh \
    && sed -i -e 's/port="8090"/port="8090" secure="${catalinaConnectorSecure}" scheme="${catalinaConnectorScheme}" proxyName="${catalinaConnectorProxyName}" proxyPort="${catalinaConnectorProxyPort}"/' ${CONFLUENCE_INSTALL_DIR}/conf/server.xml

CMD ["/entrypoint.sh", "-fg"]
#ENTRYPOINT ["/sbin/tini", "--"]