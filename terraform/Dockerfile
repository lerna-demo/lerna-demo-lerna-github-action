FROM ubuntu:latest

ENV TF_CLI_VERSION="0.14.8"

RUN apt update
RUN apt install curl -y
RUN apt install unzip -y

## Install wget to check cluster availability
## Ref: https://github.com/lerna-demo/lerna-aws-setup/blob/d4adae0a70573393fd68424d3ec1bdc7382064d3/terraform/modules/eks/cluster/cluster.tf#L62
RUN apt install wget -y

## Installing AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install

## Installing Terraform CLI
RUN curl "https://releases.hashicorp.com/terraform/${TF_CLI_VERSION}/terraform_${TF_CLI_VERSION}_linux_amd64.zip" -o "terraform.zip" && \
    unzip terraform.zip && \
    cp ./terraform /usr/local/bin/terraform

COPY entrypoint.sh /entrypoint.sh

RUN ["chmod", "+x", "/entrypoint.sh"]

ENTRYPOINT ["/entrypoint.sh"]