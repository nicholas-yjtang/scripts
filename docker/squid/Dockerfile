FROM ubuntu:22.04
RUN apt update && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt install -y tzdata \
    build-essential cmake openssl libssl-dev wget gzip
COPY scripts/build.sh ./build.sh
RUN ./build.sh
COPY scripts/init_sslbump.sh ./init_sslbump.sh
RUN ./init_sslbump.sh
COPY conf/squid.conf /opt/squid/etc/squid.conf
RUN chown -R proxy:proxy /opt/squid
WORKDIR /opt/squid
USER proxy
COPY scripts/run.sh ./run.sh
CMD ./run.sh
