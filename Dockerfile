From debian:jessie
MAINTAINER Jose Ant. Aranda

# Set noninteractive mode for apt-get
ENV DEBIAN_FRONTEND noninteractive

# Update
RUN apt-get -y update && apt-get install -y supervisor ca-certificates dovecot-imapd dovecot-lmtpd postfix postgrey postfix-policyd-spf-python opendkim opendkim-tools spamass-milter pyzor razor libmail-dkim-perl rsyslog 

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
COPY assets/dovecot/users /etc/dovecot/users
RUN chmod 400 /etc/dovecot/users

COPY assets/postgrey/postgrey /etc/default/postgrey

COPY assets/postfix-policyd-spf-python/policyd-spf.conf /etc/postfix-policyd-spf-python/policyd-spf.conf

RUN mkdir -p /etc/opendkim
COPY assets/opendkim/mail /etc/opendkim/mail
COPY assets/opendkim/mail.txt /etc/opendkim/mail.txt
COPY assets/opendkim/KeyTable /etc/opendkim/KeyTable
COPY assets/opendkim/SigningTable /etc/opendkim/SigningTable
COPY assets/opendkim/TrustedHosts /etc/opendkim/TrustedHosts
COPY assets/opendkim/opendkim.conf /etc/opendkim.conf

RUN chown opendkim:opendkim /etc/opendkim/mail
RUN chmod 400 /etc/opendkim/mail

RUN mkdir /var/spool/postfix/opendkim
RUN chown opendkim:root /var/spool/postfix/opendkim
RUN usermod -G opendkim postfix

RUN usermod -a -G debian-spamd spamass-milter
RUN mkdir /var/spool/postfix/spamassassin
RUN chown debian-spamd:root /var/spool/postfix/spamassassin/

COPY assets/spamassassin/spamassassin /etc/default/spamassassin
COPY assets/spamassassin/spamass-milter /etc/default/spamass-milter
RUN echo "loadplugin Mail::SpamAssassin::Plugin::TextCat" >> /etc/spamassassin/init.pre
COPY assets/spamassassin/local.cf /etc/spamassassin/local.cf

COPY assets/supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Add files
ADD assets/configure.sh /opt/configure.sh
RUN chmod +x /opt/configure.sh

VOLUME ["/var/mail", "/var/lib/postgrey", "/var/lib/spamassassin"]

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
CMD /opt/configure.sh; /usr/bin/supervisord -c /etc/supervisor/supervisord.conf