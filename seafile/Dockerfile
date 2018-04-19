ARG BUILD_FROM
FROM $BUILD_FROM

ENV LANG C.UTF-8

COPY start.sh /start.sh

RUN apt update \
	apt install -y jq \
	rm -rf /tmp/* \
	rm -rf /var/lib/apt/lists/* \
	ln -fs /share/seafile /shared \
	chmod +x /start.sh 

EXPOSE 80/tcp 443/tcp

CMD ["/start.sh"]