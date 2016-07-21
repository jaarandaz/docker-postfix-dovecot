# docker-postfix-dovecot


You'll need to have ssl and opendkim keys.

To generate opendkim keys:

```
cd /etc/opendkim
opendkim-genkey -r -h sha256 -d moautoexchange.com -s mail
mv mail.private mail
```

Exposed volumes won't have required folders when used with a volume container. So maybe you have to create folders and so on.

