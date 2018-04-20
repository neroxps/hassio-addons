ARG BUILD_FROM
FROM $BUILD_FROM
ARG BUILD_ARCH

ENV LANG C.UTF-8

COPY scripts /scripts

RUN apk update && apk upgrade && apk add --no-cache jq\
	&& cp /scripts/$BUILD_ARCH/aliyun-ddns-cli /usr/bin \
	&& chmod +x /usr/bin/aliyun-ddns-cli \
	&& chmod +x /scripts/start.sh

CMD ["/scripts/start.sh"]