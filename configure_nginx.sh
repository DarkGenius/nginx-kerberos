#!/bin/sh
echo "configuring nginx..."

domain=$1
localhost=$2
remote_ip=$3
remote_port=$4
lowercasedomain=$(echo "$domain" | tr [A-Z] [a-z])

cat >  /etc/nginx/conf.d/default.conf <<EOF
server {
    listen       80;
    server_name  $localhost.$lowercasedomain;
    auth_gss on;
    auth_gss_realm $domain;
    auth_gss_format_full on;
    auth_gss_keytab /etc/nginx/user.keytab;
    auth_gss_service_name HTTP/$localhost.$lowercasedomain;

    #charset koi8-r;
    #access_log  /var/log/nginx/host.access.log  main;

    location / {
        #root   /usr/share/nginx/html;
        #index  index.html index.htm;
	proxy_pass http://$remote_ip:$remote_port;
        proxy_http_version  1.1;
        proxy_cache_bypass  \$http_upgrade;
        proxy_set_header Upgrade        \$http_upgrade;
        proxy_set_header Connection   \$http_connection;
        proxy_set_header Host              \$host;
        proxy_set_header X-Real-IP         \$remote_addr;
        proxy_set_header X-Forwarded-For   \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header X-Forwarded-Host  \$host;
        proxy_set_header X-Forwarded-Port  \$server_port;
        proxy_set_header X-Forwarded-User \$remote_user;
    }

    #error_page  404              /404.html;

    # redirect server error pages to the static page /50x.html
    #
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }

    # proxy the PHP scripts to Apache listening on 127.0.0.1:80
    #
    #location ~ \.php$ {
    #    proxy_pass   http://127.0.0.1;
    #}

    # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
    #
    #location ~ \.php$ {
    #    root           html;
    #    fastcgi_pass   127.0.0.1:9000;
    #    fastcgi_index  index.php;
    #    fastcgi_param  SCRIPT_FILENAME  /scripts\$fastcgi_script_name;
    #    include        fastcgi_params;
    #}

    # deny access to .htaccess files, if Apache's document root
    # concurs with nginx's one
    #
    #location ~ /\.ht {
    #    deny  all;
    #}
}
EOF

