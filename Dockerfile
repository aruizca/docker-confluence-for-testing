FROM ubuntu:18.04
LABEL MAINTAINER @aruizca - Angel Ruiz

ENV JAVA_HOME /opt/jre
ENV PATH $JAVA_HOME/bin:$PATH
# https://confluence.atlassian.com/doc/confluence-home-and-other-important-directories-590259707.html
ENV CONFLUENCE_HOME          /var/atlassian/application-data/confluence
ENV CONFLUENCE_INSTALL_DIR   /opt/atlassian/confluence

ARG CONFLUENCE_VERSION
ARG JAVA_VERSION

# Install some utilse
RUN apt-get update \
&& apt-get install -yq wget curl bash jq ttf-dejavu ca-certificates tzdata locales locales-all \
&& update-ca-certificates \
&& rm -rf /var/lib/{apt,dpkg,cache,log}/ /tmp/* /var/tmp/*

# Use jabba JVM Manger to install Oracle JRE 1.8
RUN curl -sL https://github.com/shyiko/jabba/raw/master/install.sh | JABBA_COMMAND="install ${JAVA_VERSION} -o ${JAVA_HOME}" bash

# If no Confluence version provided via command line argument, the last available version will be installed

# Expose HTTP, Synchrony ports and Debug ports
EXPOSE 8090 8091 5005

WORKDIR $CONFLUENCE_HOME

RUN mkdir scripts
COPY scripts/entrypoint.sh /scripts/entrypoint.sh

# Download required Confluence version
RUN [ -n "${CONFLUENCE_VERSION}" ] || export CONFLUENCE_VERSION=$(curl -s https://marketplace.atlassian.com/rest/2/applications/confluence/versions/latest | jq -r '.version') \
    && export DOWNLOAD_URL="http://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-${CONFLUENCE_VERSION}.tar.gz" \
    && mkdir -p                          ${CONFLUENCE_INSTALL_DIR} \
    && curl -L                           ${DOWNLOAD_URL} | tar -xz --strip-components=1 -C "$CONFLUENCE_INSTALL_DIR"

# Perform settings modifications
RUN sed -i -e 's/-Xms\([0-9]\+[kmg]\) -Xmx\([0-9]\+[kmg]\)/-Xms\${JVM_MINIMUM_MEMORY:=\1} -Xmx\${JVM_MAXIMUM_MEMORY:=\2} \${JVM_SUPPORT_RECOMMENDED_ARGS} -Dconfluence.home=\${CONFLUENCE_HOME} -Dsynchrony.proxy.healthcheck.disabled=true/g' ${CONFLUENCE_INSTALL_DIR}/bin/setenv.sh \
    && sed -i -e 's/<Context path=""/<Context path="\/confluence"/g' ${CONFLUENCE_INSTALL_DIR}/conf/server.xml \
    && sed -i -e 's/\${confluence.context.path}/\/confluence/g' ${CONFLUENCE_INSTALL_DIR}/conf/server.xml

CMD ["/scripts/entrypoint.sh", "-fg"]