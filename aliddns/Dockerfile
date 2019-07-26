# Prepare
ARG BUILD_FROM
FROM $BUILD_FROM as Prepare
ARG BUILD_ARCH

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk update && apk add axel \
    && version=$(wget -q -O - https://api.github.com/repos/chenhw2/aliyun-ddns-cli/commits/master | sed -n '{/sha/p; /date/p;}'| sed 's/.* \"//g' | cut -c1-10 | tr '[:lower:]' '[:upper:]' | sed 'N;s/\n/@/g' | head -1) \
    && if [[ ${BUILD_ARCH} == 'armhf' || ${BUILD_ARCH} == 'armv7' || ${BUILD_ARCH} == 'aarch64' ]];then arch='arm' ;fi \
    && if [[ ${BUILD_ARCH} == 'i386' ]];then arch='linux-386';fi \
    && if [[ ${BUILD_ARCH} == 'amd64' ]];then arch='linux-amd64';fi \
    && mkdir /app \
    && axel -n 32 -o /app/aliddns_cli.tar.gz "https://github.com/honwen/aliyun-ddns-cli/releases/download/v${version#*@}/aliddns_${arch}-${version}.tar.gz" \
    && tar xzf /app/aliddns_cli.tar.gz -C /app \
    && if [[ ${BUILD_ARCH} == 'i386' ]];then mv /app/aliddns_linux_386 /app/aliyun-ddns-cli;fi \
    && if [[ ${BUILD_ARCH} == 'amd64' ]];then mv /app/aliddns_linux_amd64 /app/aliyun-ddns-cli;fi \
    && if [[ ${BUILD_ARCH} == 'armhf' || ${BUILD_ARCH} == 'armv7' || ${BUILD_ARCH} == 'aarch64' ]];then mv /app/aliddns_arm7 /app/aliyun-ddns-cli;fi 

# Aliddns_cli
FROM $BUILD_FROM
ARG BUILD_ARCH

ENV LANG C.UTF-8

COPY start.sh /start.sh
COPY --from=Prepare /app/aliyun-ddns-cli /usr/bin/aliyun-ddns-cli

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && apk update && apk upgrade && apk add --no-cache jq\
    && chmod +x /usr/bin/aliyun-ddns-cli \
    && chmod +x /start.sh

CMD ["/scripts/start.sh"]