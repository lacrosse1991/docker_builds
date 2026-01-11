FROM debian:stable-20251229-slim

# renovate: suite=stable depName=rsyslog
ENV RSYSLOG_VERSION="8.2504.0-1"

# renovate: suite=stable depName=rsyslog-gnutls
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
