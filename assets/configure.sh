#!/bin/bash

# Postfix runs inside a chroot, it needs this for dns-lookup
cp -f /etc/resolv.conf /var/spool/postfix/etc/resolv.conf
cp -f /etc/services /var/spool/postfix/etc/services

# If you use a docker volume you need to create these folders
mkdir -p /var/mail/vmail
chown -R vmail:vmail /var/mail/vmail

chown postgrey:postgrey /var/lib/postgrey

chown -R debian-spamd:debian-spamd /var/lib/spamassassin
sa-update
sa-compile

mkdir -p /var/lib/spamassassin/.spamassassin
mkdir -p /var/lib/spamassassin/.razor
mkdir -p /var/lib/spamassassin/.pyzor

pyzor --homedir /var/lib/spamassassin/.pyzor discover
razor-admin -home=/var/lib/spamassassin/.razor -register
razor-admin -home=/var/lib/spamassassin/.razor -create
razor-admin -home=/var/lib/spamassassin/.razor -discover

cat > /var/lib/spamassassin/.razor <<EOF
# Created with all default values
debuglevel             = 3
identity               = identity
ignorelist             = 0
listfile_catalogue     = servers.catalogue.lst
listfile_discovery     = servers.discovery.lst
listfile_nomination    = servers.nomination.lst
logfile                = razor-agent.log
logic_method           = 4
min_cf                 = ac
razordiscovery         = discovery.razor.cloudmark.com
rediscovery_wait       = 172800
report_headers         = 1
turn_off_discovery     = 0
use_engines            = 4,8
whitelist              = razor-whitelist
razorhome              = /var/lib/spamassassin/.razor
EOF

mkdir -p /var/mail/vmail/sieve-before
mkdir -p /var/mail/vmail/sieve-after
chown -R vmail:vmail /var/mail/vmail

cat > /var/mail/vmail/sieve-before/masterfilter.sieve <<EOF
require ["envelope", "fileinto", "imap4flags", "regex"];
 
# File low-level spam in spam bucket, and viruses in Infected folder
if anyof (header :contains "X-Spam-Level" "*****",
          header :contains "X-Virus-Status" "Infected") {
    if header :contains "X-Spam-Level" "*****" {
        fileinto "Junk";
        setflag "\\Seen";
    }
    else {
        fileinto "Infected";
    }
}
EOF

