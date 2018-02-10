ARG BUILD_FROM
FROM $BUILD_FROM

ENV LANG C.UTF-8

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
	&& echo "http://mirrors.ustc.edu.cn/alpine/edge/testing" >> /etc/apk/repositories \
	&& apk update && apk upgrade && apk add --no-cache \
	python git \
	&& cd / \
	&& git clone https://github.com/Yonsm/HAExtra.git 
EXPOSE 8122/tcp
WORKDIR /HAExtra/hagenie

CMD ["sh", "-c", "python hagenie.py"]
