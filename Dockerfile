# FROM codercom/code-server:latest
FROM quay.io/spivegin/tlmbasedebian



USER root
RUN mkdir -p /opt/tmp /opt/src /opt/go/bin
ENV GOPATH=/opt/src/ \
    GOBIN=/opt/go/bin \
    PATH=/opt/go/bin:$PATH \
    GO_VERSION=1.14.1 \
    GOPROXY=direct \
    GOSUMDB=off

#Install Golang
ADD https://storage.googleapis.com/golang/go${GO_VERSION}.linux-amd64.tar.gz /opt/tmp/


RUN apt-get update -y && apt-get -y upgrade  && apt-get install -y unzip curl git  && apt upgrade -y &&\
    tar -C /opt/ -xzf /opt/tmp/go${GO_VERSION}.linux-amd64.tar.gz &&\
    chmod +x /opt/go/bin/* &&\
    ln -s /opt/go/bin/* /bin/ &&\
    rm /opt/tmp/go${GO_VERSION}.linux-amd64.tar.gz &&\
    apt-get autoclean && apt-get autoremove &&\
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

RUN curl -fOL https://github.com/cdr/code-server/releases/download/v3.4.0/code-server_3.4.0_amd64.deb &&\
    dpkg -i code-server_3.4.0_amd64.deb &&\
    rm code-server_3.4.0_amd64.deb

# Install Dart.
ENV DART_VERSION 2.5.2
# https://storage.googleapis.com/dart-archive/channels/dev/release/${DART_VERSION}/sdk/dartsdk-linux-x64-release.zip
# https://storage.googleapis.com/dart-archive/channels/stable/release/${DART_VERSION}/sdk/dartsdk-linux-x64-release.zip
RUN mkdir /opt/dart /opt/dart/code /opt/dart/data /opt/dart/bin /opt/dartlang
RUN apt-get update && apt-get install -y unzip curl git &&\
    cd /opt/dartlang/ && \
    curl -O https://storage.googleapis.com/dart-archive/channels/stable/release/${DART_VERSION}/sdk/dartsdk-linux-x64-release.zip && \
    unzip dartsdk-linux-x64-release.zip && \
    rm dartsdk-linux-x64-release.zip &&\
    echo "\nexport PATH=/opt/dartlang/dart-sdk/bin:\$PATH" >> /etc/profile &&\
    apt-get autoclean && apt-get autoremove &&\
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

ENV PATH /opt/dartlang/dart-sdk/bin:$PATH

# Define working directory.
WORKDIR /home/coder
RUN code-server --install-extension dart-code.dart-code &&\
    code-server --install-extension ms-vscode.go &&\
    code-server --install-extension rstuven.iferrblocks &&\
    code-server --install-extension tyriar.shell-launcher &&\
    code-server --install-extension rokoroku.vscode-theme-darcula &&\
    code-server --install-extension isudox.vscode-jetbrains-keybindings
# Define default command.
CMD ["code-server", "--auth", "none", "--bind-addr", "0.0.0.0:8080", "--disable-telemetry"]
#ENTRYPOINT ["/bin/bash"]
