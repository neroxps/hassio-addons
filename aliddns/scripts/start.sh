#!/bin/bash
OPTIONS="/data/options.json"

AKID="$(jq -r ".akid" $OPTIONS )"
AKSCT="$(jq -r ".aksct" $OPTIONS )"
DOMAIN="$(jq -r ".domain" $OPTIONS )"
REDO="$(jq -r ".redo" $OPTIONS )"
if [[ "$REDO" == "" ]]; then
	REDO="600"
fi
IPAPI="$(jq -r ".ipapi" $OPTIONS )"
if [[ "$IPAPI" == "" ]]; then
	IPAPI="[IPAPI-GROUP]"
fi

# Run aliyun-ddns-cli
aliyun-ddns-cli \
    --id ${AKID} \
    --secret ${AKSCT} \
    --ipapi ${IPAPI} \
    auto-update \
    --domain ${DOMAIN} \
    --redo ${REDO}