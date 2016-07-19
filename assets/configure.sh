# Postfix runs inside a chroot, it needs this for dns-lookup
cp -f /etc/resolv.conf /var/spool/postfix/etc/resolv.conf
cp -f /etc/services /var/spool/postfix/etc/services

# If you use a docker volume you need to create these folders
mkdir -p /var/mail/vmail
chown -R vmail:vmail /var/mail/vmail
