FROM ubuntu:22.04
RUN apt update && apt install -y \
    build-essential wget curl openssl libssl-dev ldap-utils groff-base
RUN mkdir -p /opt/openldap/scripts
WORKDIR /opt/openldap
COPY scripts/compile.sh scripts
RUN scripts/compile.sh
COPY scripts scripts
COPY conf conf
ARG HOSTNAME
ENV HOSTNAME=$HOSTNAME
RUN scripts/build.sh
EXPOSE 389 636
CMD scripts/start.sh