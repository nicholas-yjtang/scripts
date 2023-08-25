FROM ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
RUN apt update && apt install -y apache2 mysql-server
RUN apt update && apt install -y php libapache2-mod-php php-mysql
RUN apt update && apt install unzip curl
COPY bWAPPv2.2.zip /var/www/html/
RUN mkdir /opt/bwapp
WORKDIR /opt/bwapp
COPY scripts/install.sh install.sh
COPY scripts/install.sql install.sql
COPY scripts/run.sh run.sh
RUN ./install.sh
EXPOSE 80
CMD ./run.sh