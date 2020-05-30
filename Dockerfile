FROM quay.io/spivegin/gitonly:latest AS git

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

RUN git config --global user.name "quadtone" &&\
    git config --global user.email "quadtone@txtsme.com"

COPY --from=git /root/.ssh /root/.ssh
RUN ssh-keyscan -H github.com > ~/.ssh/known_hosts &&\
    ssh-keyscan -H gitlab.com >> ~/.ssh/known_hosts

ENV deploy=c1f18aefcb3d1074d5166520dbf4ac8d2e85bf41
RUN git config --global url.git@github.com:.insteadOf https://github.com/ &&\
    git config --global url.git@gitlab.com:.insteadOf https://gitlab.com/ &&\
    git config --global url."https://${deploy}@sc.tpnfc.us/".insteadOf "https://sc.tpnfc.us/"

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
WORKDIR /root/coder
RUN code-server --install-extension dart-code.dart-code &&\
    code-server --install-extension ms-vscode.go &&\
    code-server --install-extension rstuven.iferrblocks &&\
    code-server --install-extension tyriar.shell-launcher &&\
    code-server --install-extension rokoroku.vscode-theme-darcula &&\
    code-server --install-extension isudox.vscode-jetbrains-keybindings
# Define default command.
CMD ["code-server", "--auth", "none", "--bind-addr", "0.0.0.0:8080", "--disable-telemetry"]
#ENTRYPOINT ["/bin/bash"]
