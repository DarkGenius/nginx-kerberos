#!/bin/sh

./opt/install/configure_nginx.sh $domain $localhost $remote_ip $remote_port
./opt/install/configure_kerberos.sh $domain $dc
./opt/install/configure_dns.sh $domain $dc $dc_ip
./opt/install/setupkeytab.sh $username $domain $password $kvno $localhost

mv user.keytab /etc/nginx/user.keytab
chmod 740 /etc/nginx/user.keytab
chown root:nginx /etc/nginx/user.keytab

echo "Running nginx"

exec nginx

