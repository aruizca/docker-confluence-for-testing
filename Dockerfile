FROM anapsix/alpine-java
LABEL MAINTAINER="@aruizca - Angel Ruiz"

# Install some utilse
RUN apk update \
 && apk add ca-certificates \
 && apk add jq \
 && apk add curl \
 && apk add ttf-dejavu \
 && update-ca-certificates \
 && rm -rf /var/cache/apk/

# https://confluence.atlassian.com/doc/confluence-home-and-other-important-directories-590259707.html
ENV CONFLUENCE_HOME          /var/atlassian/application-data/confluence
ENV CONFLUENCE_INSTALL_DIR   /opt/atlassian/confluence

# If no Confluence version provided via command line argument, the last available version will be installed
ARG CONFLUENCE_VERSION

# Expose HTTP, Synchrony ports and Debug ports
EXPOSE 8090 8091 5005

WORKDIR $CONFLUENCE_HOME

COPY entrypoint.sh /entrypoint.sh

RUN [ -n "${CONFLUENCE_VERSION}" ] || export CONFLUENCE_VERSION=$(curl -s https://marketplace.atlassian.com/rest/2/applications/confluence/versions/latest | jq -r '.version') \
    && echo "${CONFLUENCE_VERSION}" \
    && export DOWNLOAD_URL="http://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-${CONFLUENCE_VERSION}.tar.gz" \
    && echo "${DOWNLOAD_URL}" \
    && mkdir -p                          ${CONFLUENCE_INSTALL_DIR} \
    && curl -L                           ${DOWNLOAD_URL} | tar -xz --strip-components=1 -C "$CONFLUENCE_INSTALL_DIR" \
    && sed -i -e 's/-Xms\([0-9]\+[kmg]\) -Xmx\([0-9]\+[kmg]\)/-Xms\${JVM_MINIMUM_MEMORY:=\1} -Xmx\${JVM_MAXIMUM_MEMORY:=\2} \${JVM_SUPPORT_RECOMMENDED_ARGS} -Dconfluence.home=\${CONFLUENCE_HOME} -Dsynchrony.proxy.healthcheck.disabled=true/g' ${CONFLUENCE_INSTALL_DIR}/bin/setenv.sh

CMD ["/entrypoint.sh", "-fg"]
    