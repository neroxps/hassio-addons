#!/bin/bash
OPTIONS="/data/options.json"

# Chack Seafile dir
if [ ! -d /share/seafile ] ; then
	mkdir /share/seafile
fi

# Setup Seafile
export SEAFILE_SERVER_LETSENCRYPT=$(jq -r ".seafile_server_letsencrypt" $OPTIONS)
export SEAFILE_SERVER_HOSTNAME=$(jq -r ".seafile_server_hostname" $OPTIONS)
export SEAFILE_ADMIN_EMAIL=$(jq -r ".seafile_admin_email" $OPTIONS)
export SEAFILE_ADMIN_PASSWORD=$(jq -r ".seafile_admin_password" $OPTIONS)

# Run Seafile
/sbin/my_init -- /scripts/start.py