FROM ubuntu:22.04
RUN apt update && apt install -y \
    build-essential wget curl openssl libssl-dev ldap-utils groff-base
RUN mkdir -p /opt/openldap
WORKDIR /opt/openldap
COPY scripts scripts
RUN scripts/build.sh