FROM debian:bullseye

LABEL maintainer="S.Bay (info@space2place.de)"

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8

# Default versions
ENV TELEGRAF_VERSION 1.19.3-1
ENV INFLUXDB_VERSION 1.8.9
ENV GRAFANA_VERSION 8.1.2
ENV CHRONOGRAF_VERSION 1.9.0
ENV GF_DATABASE_TYPE=sqlite3

# Clear previous sources
RUN rm /var/lib/apt/lists/* -vf

# Base dependencies

# Add new sources
COPY aptitude/sources.list /etc/apt/sources.list

#RUN curl -s https://repos.influxdata.com/influxdb.key | gpg --dearmor | tee /usr/share/keyrings/influxdb.gpg >/dev/null && \
# echo "deb https://repos.influxdata.com/debian bullseye stable" | tee /etc/apt/sources.list.d/influxdb.list

#RUN curl -s https://packages.grafana.com/gpg.key  | gpg --dearmor | tee /usr/share/keyrings/grafana.gpg >/dev/null && \
# echo "deb https://packages.grafana.com/oss/deb stable main" | tee /etc/apt/sources.list.d/grafana.list

RUN apt-get -y update && \
 apt-get -y dist-upgrade && \
 apt-get -y install \
 apt-utils \
 vim \
 nano \
 supervisor \
 ca-certificates \
 curl \
 git \
 htop \
 libfontconfig \
 mc \
 net-tools \
 openssh-server \
 gnupg \
 gnupg2 \
 gnupg1 \
 snmp \
 syslog-ng \
 snmp-mibs-downloader \
 apt-transport-https \
 software-properties-common \
 python \
 collectd \
 python3-pip \
 python3-lxml \
 libxml2-dev \
 libxslt-dev \
 python3-dev \
 wget && \
 curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
 apt-get install -y nodejs

# Configure Supervisord, SSH and base env
COPY supervisord/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

WORKDIR /root
RUN mkdir -p /var/run/sshd && \
 mkdir -p /var/log/supervisor && \
 echo 'root:root' | chpasswd && \
 rm -rf .ssh && \
 rm -rf .profile && \
 mkdir .ssh

RUN printf '#!/bin/sh\nexit 0' > /usr/sbin/policy-rc.d

COPY bash/profile .profile
COPY bash/.vimrc .vimrc

# Synology SNMP
COPY synology/* /usr/share/snmp/mibs/
RUN chown root:root /usr/share/snmp/mibs/
RUN chmod 755 /usr/share/snmp/mibs/

# Install InfluxDB
RUN wget https://dl.influxdata.com/influxdb/releases/influxdb_${INFLUXDB_VERSION}_amd64.deb && \
 dpkg -i influxdb_${INFLUXDB_VERSION}_amd64.deb && rm influxdb_${INFLUXDB_VERSION}_amd64.deb

# Configure InfluxDB
COPY influxdb/influxdb.conf /etc/influxdb/influxdb.conf
COPY influxdb/init.sh /etc/init.d/influxdb
RUN chmod +x /etc/init.d/influxdb

#install syslog-ng 
COPY syslog/syslog-ng.conf /etc/syslog-ng/syslog-ng.conf

# Install Telegraf
RUN wget https://dl.influxdata.com/telegraf/releases/telegraf_${TELEGRAF_VERSION}_amd64.deb && \
 dpkg -i telegraf_${TELEGRAF_VERSION}_amd64.deb && rm telegraf_${TELEGRAF_VERSION}_amd64.deb

# Configure Telegraf
RUN mv -f /etc/telegraf/telegraf.conf /etc/telegraf/telegraf.conf.default 
COPY telegraf/telegraf.conf /etc/telegraf/telegraf.conf
COPY telegraf/init.sh /etc/init.d/telegraf
RUN chmod +x /etc/init.d/telegraf

# Install Chronograf
RUN wget https://dl.influxdata.com/chronograf/releases/chronograf_${CHRONOGRAF_VERSION}_amd64.deb && \
 dpkg -i chronograf_${CHRONOGRAF_VERSION}_amd64.deb  && rm chronograf_${CHRONOGRAF_VERSION}_amd64.deb

# Install PIP packages
RUN pip install fritzconnection
RUN pip install requests
RUN pip install fritzcollectd

# Install Grafana
RUN wget https://dl.grafana.com/oss/release/grafana_${GRAFANA_VERSION}_amd64.deb && \
 dpkg -i grafana_${GRAFANA_VERSION}_amd64.deb && rm grafana_${GRAFANA_VERSION}_amd64.deb

# Configure Grafana with provisioning
ADD grafana/provisioning /etc/grafana/provisioning
COPY grafana/grafana.ini /etc/grafana/grafana.ini

# Install grafana-image-renderer
RUN apt-get -y install \
 libxdamage1 \
 libxext6 \
 libxi6 \
 libxtst6 \
 libnss3 \
 libnss3 \
 libcups2 \
 libxss1 \
 libxrandr2 \
 libasound2 \
 libatk1.0-0 \
 libatk-bridge2.0-0 \
 libpangocairo-1.0-0 \
 libpango-1.0-0 \
 libcairo2 \
 libatspi2.0-0 \
 libgtk3.0-cil \
 libgdk3.0-cil \
 libx11-xcb-dev \
 libgbm1 \
 libxshmfence1

RUN /usr/sbin/grafana-cli plugins install grafana-image-renderer

COPY root-scripts/backup-grafana-image-renderer.sh /tmp/backup-grafana-image-renderer.sh
RUN chmod +x /tmp/backup-grafana-image-renderer.sh
RUN /tmp/backup-grafana-image-renderer.sh

COPY root-scripts/copy-grafana-image-renderer.sh /root/copy-grafana-image-renderer.sh
RUN chmod +x /root/copy-grafana-image-renderer.sh

COPY root-scripts/container-startup.sh /root/container-startup.sh
RUN chmod +x /root/container-startup.sh

EXPOSE 22/tcp 3003/tcp 8086/tcp 8888/tcp 8125/udp 514/udp

# Cleanup
RUN apt-get clean && \
 rm -rf /var/lib/apt/lists/*  /var/tmp/*

CMD ["/root/container-startup.sh"]

