From debian:jessie
MAINTAINER Jose Ant. Aranda

# Set noninteractive mode for apt-get
ENV DEBIAN_FRONTEND noninteractive

# Update
RUN apt-get -y update && apt-get install -y supervisor ca-certificates dovecot-imapd dovecot-lmtpd postfix postgrey postfix-policyd-spf-python rsyslog

RUN apt-get purge exim4 exim4-*

RUN echo "DOMAIN.com" > /etc/mailname

COPY assets/certs/ssl-key-decrypted-mail.key /etc/ssl/private/
COPY assets/certs/ssl-chain-mail.pem /etc/ssl/private/

RUN chmod 400 /etc/ssl/private/*.*

COPY assets/postfix/main.cf /etc/postfix/main.cf
RUN chmod 600 /etc/postfix/main.cf

COPY assets/postfix/master.cf /etc/postfix/master.cf
RUN chmod 600 /etc/postfix/master.cf

COPY assets/postfix/virtual_aliases /etc/postfix/virtual_aliases
RUN chmod 600 /etc/postfix/virtual_aliases
RUN postmap /etc/postfix/virtual_aliases

RUN touch /etc/postfix/sender_access
RUN postmap /etc/postfix/sender_access

RUN groupadd -g 5000 vmail
RUN useradd -g vmail -u 5000 vmail -d /var/mail/vmail -m

COPY assets/dovecot/99-mail-stack-delivery.conf /etc/dovecot/conf.d/99-mail-stack-delivery.conf

COPY assets/postgrey/postgrey /etc/default/postgrey

COPY assets/postfix-policyd-spf-python/policyd-spf.conf /etc/postfix-policyd-spf-python/policyd-spf.conf

COPY assets/supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

VOLUME ["/var/mail"]

# SMTP
EXPOSE 25
# SMTPS
EXPOSE 465
# IMAP
EXPOSE 587
# IMAP over SSL
EXPOSE 993
# SMTPS
EXPOSE 143

# Run
CMD /usr/bin/supervisord  -c /etc/supervisor/supervisord.conf