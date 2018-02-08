FROM homeassistant/amd64-builder
COPY daemon.json /etc/default/docker
WORKDIR /data
ENTRYPOINT ["/usr/bin/builder.sh"]
