#! /usr/bin/env bash
set -e # exit on error

# Variables
if [ -z "$SMTP_LOGIN" -o -z "$SMTP_PASSWORD" ] ; then
	echo "SMTP_LOGIN and SMTP_PASSWORD _must_ be defined"
	exit 1
fi
export SMTP_LOGIN SMTP_PASSWORD POSTFIX_DEF_EMAIL
export EXT_RELAY_HOST=${EXT_RELAY_HOST:-"email-smtp.us-west-2.amazonaws.com"}
export EXT_RELAY_PORT=${EXT_RELAY_PORT:-"25"}
export RELAY_HOST_NAME=${RELAY_HOST_NAME:-"mail-relay.mail-relay.aws.docker"}
export ACCEPTED_NETWORKS=${ACCEPTED_NETWORKS:-"172.0.0.0/8 10.0.0.0/8"}

echo $RELAY_HOST_NAME > /etc/mailname

# Templates
j2 /root/conf/postfix-main.cf > /etc/postfix/main.cf
j2 /root/conf/sasl_passwd > /etc/postfix/sasl_passwd
j2 /root/conf/postfix-virtual-regexp > /etc/postfix/virtual-regexp
postmap /etc/postfix/sasl_passwd

# Launch
rm -f /var/spool/postfix/pid/*.pid
tail -F /var/log/mail.log &
exec /usr/bin/supervisord -n
