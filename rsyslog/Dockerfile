FROM debian:trixie-slim@sha256:cedb1ef40439206b673ee8b33a46a03a0c9fa90bf3732f54704f99cb061d2c5a

# renovate: datasource=deb depName=rsyslog registryUrl=https://deb.debian.org/debian?suite=trixie&components=main&binaryArch=amd64
ENV RSYSLOG_VERSION="8.2504.0-1"

# renovate: datasource=deb depName=rsyslog-gnutls registryUrl=https://deb.debian.org/debian?suite=trixie&components=main&binaryArch=amd64
ENV RSYSLOG_GNUTLS_VERSION="8.2504.0-1"


RUN apt-get -y update && apt-get install rsyslog="${RSYSLOG_VERSION}" rsyslog-gnutls="${RSYSLOG_GNUTLS_VERSION}" -y
RUN mkdir /rsyslog-bin
RUN chown -R 1001:1001 /var/run
RUN chown -R 1001:1001 /usr/lib/rsyslog

USER 1001

EXPOSE 1514/udp 
EXPOSE 1514/tcp

WORKDIR /rsyslog-bin

CMD ["/usr/sbin/rsyslogd", "-n", "-f/etc/rsyslog.conf"]
