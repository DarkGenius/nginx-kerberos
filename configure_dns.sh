echo "domain: $1"
domain=$1
uppercasedomain=$(echo "$domain" | tr [a-z] [A-Z])
lowercasedomain=$(echo "$domain" | tr [A-Z] [a-z])
dc=$2
dcip=$3

echo "$domain $lowercasedomain"
echo "configuring hosts"
echo ${dcip} ${dc}.${lowercasedomain} >> /etc/hosts
echo ${dcip} ${lowercasedomain} >> /etc/hosts
echo "Done hosts:"
cat /etc/hosts
