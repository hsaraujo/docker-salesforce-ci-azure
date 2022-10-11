FROM amd64/ubuntu:20.04
LABEL maintainer="Heitor Araujo <heitor.saraujo@gmail.com>"
ARG DEBIAN_FRONTEND=noninteractive
RUN apt update
RUN apt-get install bash
#RUN apt-get install openssh
RUN echo "Y" | apt-get install git
RUN echo "Y" | apt-get install zip
RUN echo "Y" | apt-get install wget
RUN echo "Y" | apt-get install jq
RUN apt -y install xdg-utils
RUN apt -y install azure-cli
#RUN echo "Y" | apt-get install xmlstarlet
RUN echo "Y" | apt-get install python3
RUN echo "Y" | apt-get install python3-pip
RUN echo "Y" | apt-get install curl
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN apt -y install nodejs
# RUN apt -y install npm
RUN npm install -g sf-packager
RUN npm install -g jsforce-metadata-tools
RUN npm install -g sfdx-cli@7.166.1
RUN npm install -g sfdx-packager
RUN npm install -g semver

# Set up Java 8
#RUN apt-get install openjdk8
RUN apt -y install openjdk-8-jdk
RUN ls /usr/lib/jvm/java-1.8.0-openjdk-amd64
ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk-amd64
# Set up PMD
ENV PMD_VERSION=6.50.0

ENV XDG_DATA_HOME=/sfdx_plugins/.local/share \
    XDG_CONFIG_HOME=/sfdx_plugins/.config \
    XDG_CACHE_HOME=/sfdx_plugins/.cache

RUN echo 'Y' | sfdx plugins:install sfdx-git-delta
RUN echo "Y" | sfdx plugins:install sfdx-git-packager
RUN echo 'y' | sfdx plugins:install sfpowerkit

# Create symbolic link from sh to bash
# Create isolated plugins directory with rwx permission for all users
# Azure pipelines switches to a container-user which does not have access
# to the root directory where plugins are normally installed
RUN ln -sf bash /bin/sh && \
    mkdir -p $XDG_DATA_HOME && \
    mkdir -p $XDG_CONFIG_HOME && \
    mkdir -p $XDG_CACHE_HOME && \
    chmod -R 777 sfdx_plugins && \
    export JAVA_HOME && \
    export XDG_DATA_HOME && \
    export XDG_CONFIG_HOME && \
    export XDG_CACHE_HOME

RUN curl -sLO https://github.com/pmd/pmd/releases/download/pmd_releases%2F${PMD_VERSION}/pmd-bin-${PMD_VERSION}.zip && \
    unzip pmd-bin-*.zip && \
    rm pmd-bin-*.zip && \
    echo '#!/bin/bash' >> /usr/local/bin/pmd && \
    echo '#!/bin/bash' >> /usr/local/bin/cpd && \
    echo '/pmd-bin-6.50.0/bin/run.sh pmd "$@"' >> /usr/local/bin/pmd && \
    echo '/pmd-bin-6.50.0/bin/run.sh cpd "$@"' >> /usr/local/bin/cpd && \
    chmod +x /usr/local/bin/pmd && \
    chmod +x /usr/local/bin/cpd