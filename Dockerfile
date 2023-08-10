FROM python:3.6

ARG pip_installer="https://bootstrap.pypa.io/get-pip.py"
ARG awscli_version="1.16.168"

# install aws-cli
RUN pip install awscli==${awscli_version}
RUN pip3 install --upgrade awscli

# install sam
RUN pip install --user --upgrade aws-sam-cli
ENV PATH $PATH:/root/.local/bin

# install command.
RUN apt-get update && apt-get install -y less vim wget unzip

# install terraform.
# https://azukipochette.hatenablog.com/entry/2018/06/24/004354
RUN wget https://releases.hashicorp.com/terraform/1.5.5/terraform_1.5.5_linux_amd64.zip && \
    unzip ./terraform_1.5.5_linux_amd64.zip -d /usr/local/bin/


# create workspace.
RUN mkdir /root/src

# initialize command.
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
COPY .aws /root/.aws


# Copy a file and a folder
COPY confirm-pwd-ls-cd.sh /root/src
COPY test_env-tf /root/src/test_env-tf 

# Defined workdir 
WORKDIR /root/src
