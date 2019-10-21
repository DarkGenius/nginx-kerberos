#!/bin/sh

echo "configuring kerberos..."
domain=$1
dc=$2
uppercasedomain=$(echo "$domain" | tr [a-z] [A-Z])
lowercasedomain=$(echo "$domain" | tr [A-Z] [a-z])

cat > /etc/krb5.conf << EOF
[libdefaults]
	default_realm = $uppercasedomain

	# The following krb5.conf variables are only for MIT Kerberos.
	kdc_timesync = 1
	ccache_type = 4
	forwardable = true
	proxiable = true


	# The following libdefaults parameters are only for Heimdal Kerberos.
	fcc-mit-ticketflags = true

[realms]
	$uppercasedomain = {
		kdc = $dc.$lowercasedomain
		admin_server = $dc.$lowercasedomain
	}

[domain_realm]
	.$lowercasedomain = $uppercasedomain
	$lowercasedomain = $uppercasedomain
EOF

echo "kerberos configured as: "
cat /etc/krb5.conf

