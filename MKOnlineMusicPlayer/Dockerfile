ARG BUILD_FROM
FROM $BUILD_FROM

ENV LANG C.UTF-8

COPY bootstrap /bootstrap

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
	&& echo "http://mirrors.ustc.edu.cn/alpine/edge/testing" >> /etc/apk/repositories \
	&& apk update && apk upgrade && apk add --no-cache \
	nginx \
	php7-fpm \
	php7-json \
	php7-curl \
	php7-openssl \
	libressl \
	jq \
	curl \
	&& sed -i "s%;error_log\ =\ /var/log/php-fpm/error.log%error_log\ =\ /var/log/php-fpm/error.log%" /etc/php7/php-fpm.conf \
	&& mkdir /run/nginx \
	&& mv /bootstrap/config/nginx/commons.conf /etc/nginx/conf.d/ \
	&& mv /bootstrap/config/nginx/http.conf /etc/nginx/conf.d/ \
	&& cp /usr/sbin/php-fpm7 /usr/bin/php-fpm \
	&& rm -f /etc/nginx/conf.d/default.conf \
	&& chmod +x /bootstrap/start.sh

EXPOSE 80/tcp

CMD ["/bootstrap/start.sh"]