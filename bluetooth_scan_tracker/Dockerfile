ARG BUILD_FROM
FROM $BUILD_FROM
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories && apk update && apk add --no-cache bluez bluez-deprecated jq mosquitto-clients
COPY run.sh /
RUN chmod a+x /run.sh
CMD [ "/run.sh" ]
