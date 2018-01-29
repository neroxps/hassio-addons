ARG BUILD_FROM
FROM $BUILD_FROM

ENV LANG C.UTF-8

ADD tmall-bot-x1 /bootstrap/tmall-bot-x1
COPY start.sh /bootstrap/

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
	&& echo "http://mirrors.ustc.edu.cn/alpine/edge/testing" >> /etc/apk/repositories \
	&& apk update && apk upgrade && apk add --no-cache \
	apache2 php7-apache2 curl ca-certificates openssl openssh git php7 php7-phar php7-json php7-iconv php7-openssl tzdata openntpd nano \
	php7-pdo \
	php7-pdo_mysql \
	php7-curl \
	jq \
	mariadb-client \
	mariadb \
	&&cp /usr/bin/php7 /usr/bin/php \
    && rm -f /var/cache/apk/* \
    && mkdir /run/apache2 \
    && sed -i "s/#LoadModule\ rewrite_module/LoadModule\ rewrite_module/" /etc/apache2/httpd.conf \
    && sed -i "s/#LoadModule\ session_module/LoadModule\ session_module/" /etc/apache2/httpd.conf \
    && sed -i "s/#LoadModule\ session_cookie_module/LoadModule\ session_cookie_module/" /etc/apache2/httpd.conf \
    && sed -i "s/#LoadModule\ session_crypto_module/LoadModule\ session_crypto_module/" /etc/apache2/httpd.conf \
    && sed -i "s/#LoadModule\ deflate_module/LoadModule\ deflate_module/" /etc/apache2/httpd.conf \
    && sed -i "s#^DocumentRoot \".*#DocumentRoot \"/config/tmall-bot-x1\"#g" /etc/apache2/httpd.conf \
    && sed -i "s#/var/www/localhost/htdocs#//config/tmall-bot-x1#" /etc/apache2/httpd.conf \
    && printf "\n<Directory \"/config/tmall-bot-x1\">\n\tAllowOverride All\n</Directory>\n" >> /etc/apache2/httpd.conf \
    && sed -i "s/#ServerName www.example.com:80/ServerName localhost/" /etc/apache2/httpd.conf \
    && chmod +x /bootstrap/start.sh

EXPOSE 80
CMD ["/bootstrap/start.sh"]
