ARG BUILD_FROM
FROM $BUILD_FROM

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
  && echo "http://mirrors.ustc.edu.cn/alpine/edge/testing" >> /etc/apk/repositories \
  && apk update && apk upgrade && apk add --no-cache \
  nodejs \
  nodejs-npm \
  && npm config set registry https://registry.npm.taobao.org \
  && npm install -g miio 

CMD ["/usr/bin/miio" "discover"]
