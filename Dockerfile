FROM alpine:3.10

# install packages
RUN apk add --virtual build-deps \
	 curl git build-base pcre-dev zlib-dev krb5 krb5-dev openssl ca-certificates alpine-conf samba-common-tools

# add nginx repo and install
RUN printf "@nginx %s%s%s\n" \
    "http://nginx.org/packages/mainline/alpine/v" \
    `egrep -o '^[0-9]+\.[0-9]+' /etc/alpine-release` \
    "/main" \
    | tee -a /etc/apk/repositories \
# add keys
	&& curl -o /tmp/nginx_signing.rsa.pub https://nginx.org/keys/nginx_signing.rsa.pub \
	&& mv /tmp/nginx_signing.rsa.pub /etc/apk/keys/ \
# install nginx
	&& apk add nginx@nginx 
#	&& sed -i "1idaemon off;\n" /etc/nginx/nginx.conf 

# get nginx sources
RUN mkdir -p /src/nginx && cd /src \
	&& curl -fSL `printf "https://nginx.org/download/nginx-%s.tar.gz" \`nginx -v 2>&1 >/dev/null | egrep -o "[0-9]+\.[0-9]+.[0-9]+"\`` \
		-o nginx.tar.gz \
	&& tar -xzf nginx.tar.gz -C nginx --strip-components=1 \
	&& rm nginx.tar.gz

# get and build module
RUN cd /src/nginx \
	&& git clone https://github.com/DarkGenius/spnego-http-auth-nginx-module.git

RUN cd /src/nginx \
	&& ./configure --with-compat --add-dynamic-module=spnego-http-auth-nginx-module \
	&& make modules \
	&& cp objs/ngx_http_auth_spnego_module.so /etc/nginx/modules/ \
	&& sed -i '/^pid*/a load_module modules/ngx_http_auth_spnego_module.so;' /etc/nginx/nginx.conf \
	&& sed -i "1idaemon off;\n" /etc/nginx/nginx.conf \
	&& sed -i -E "s/^(error_log.*) [a-z]*;$/\1 debug;/" /etc/nginx/nginx.conf

# Define mountable directories.
VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log/nginx", "/var/www/html"] 

COPY *.keytab /etc/nginx/
COPY entrypoint.sh /opt/install/
COPY configure_nginx.sh /opt/install/
COPY configure_dns.sh /opt/install/
COPY configure_kerberos.sh /opt/install/
COPY setupkeytab.sh /opt/install/

RUN chmod +x /opt/install/entrypoint.sh \
	&& chmod +x /opt/install/configure_nginx.sh \
	&& chmod +x /opt/install/configure_dns.sh \
	&& chmod +x /opt/install/configure_kerberos.sh \
	&& chmod +x /opt/install/setupkeytab.sh
ENTRYPOINT ["/opt/install/entrypoint.sh"]

EXPOSE 80
EXPOSE 443

