# docker-postfix-dovecot


You'll need to have ssl and opendkim keys.

To generate opendkim keys:

```
cd /etc/opendkim
opendkim-genkey -r -h sha256 -d moautoexchange.com -s mail
mv mail.private mail
```

Exposed volumes won't have required folders when used with a volume container. So maybe you have to create folders and so on.

Based on following posts:

http://arstechnica.com/information-technology/2014/03/taking-e-mail-back-part-2-arming-your-server-with-postfix-dovecot/
http://arstechnica.com/business/2014/03/taking-e-mail-back-part-3-fortifying-your-box-against-spammers/
http://arstechnica.com/information-technology/2014/04/taking-e-mail-back-part-4-the-finale-with-webmail-everything-after/

https://appbead.com/blog/how-to-setup-mail-server-on-debian-8-jessie-with-postfix-dovecot-1.html