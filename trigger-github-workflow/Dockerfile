FROM ubuntu:latest

RUN apt update
RUN apt install curl -y
RUN apt install jq -y

COPY entrypoint.sh /entrypoint.sh

RUN ["chmod", "+x", "/entrypoint.sh"]

ENTRYPOINT ["/entrypoint.sh"]