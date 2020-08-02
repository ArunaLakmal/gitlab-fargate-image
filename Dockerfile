FROM ubuntu:16.04

MAINTAINER ArunaLakmal <aruna.lakmal@tc.io>

ENV ANSIBLE_HOST_KEY_CHECKING false

ARG TINI_VERSION=v0.19.0

RUN apt-get update && \
    apt-get install -y curl && \
    curl -Lo /usr/local/bin/tini https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-amd64 && \
    chmod +x /usr/local/bin/tini

RUN apt-get update && apt-get install -y \
    wget \
    vim \
    unzip \
    curl \
    tar \
    openssh-client\
    git \
    ca-certificates \
    build-essential  \
    && apt-get install -y python-pip \
    && pip install ansible \
    && pip install awscli \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get remove -y openssh-client && \
    apt-get update -y && \
    apt-get install -y openssh-server && \
    mkdir -p /run/sshd

EXPOSE 22

ARG GITLAB_RUNNER_VERSION=v12.9.0

RUN curl -Lo /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/${GITLAB_RUNNER_VERSION}/binaries/gitlab-runner-linux-amd64 && \
    chmod +x /usr/local/bin/gitlab-runner && \
    gitlab-runner --version

RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
    apt-get install -y git-lfs && \
    git lfs install --skip-repo

RUN curl https://omnitruck.chef.io/install.sh | bash -s -- -P inspec

RUN wget --quiet https://releases.hashicorp.com/terraform/0.12.16/terraform_0.12.16_linux_amd64.zip \
    && unzip terraform_0.12.16_linux_amd64.zip \
    && mv terraform /usr/local/bin \
    && rm terraform_0.12.16_linux_amd64.zip

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["tini", "--", "/usr/local/bin/docker-entrypoint.sh"]