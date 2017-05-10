FROM ubuntu:16.04

LABEL ubuntu.version="16.04" maintainer="Alice Minotto, @ Earlham Institute"

USER root

RUN apt-get -y update && apt-get -yy install wget && \
    wget http://graphics.med.yale.edu/trim/btrim64 -P /bin/ && \
    chmod +x /bin/btrim64

WORKDIR /data/
