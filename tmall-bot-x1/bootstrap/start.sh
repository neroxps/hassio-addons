#!/bin/bash
OPTIONS="/data/options.json"
if [[ "$(jq -r ".debug" $OPTIONS)" == "true" ]]; then
	set -x
fi
HA_URL="http://hassio/homeassistant"
HA_PASSWD="${HASSIO_TOKEN}"
MYSQL_HOST="$(jq -r ".mysql_host" $OPTIONS)"
MYSQL_DB_NAME="$(jq -r ".mysql_db_name" $OPTIONS)"
MYSQL_USER="$(jq -r ".mysql_user" $OPTIONS)"
MYSQL_PASSWD="$(jq -r ".mysql_passwd" $OPTIONS)"
MYSQL_PORT="$(jq -r ".mysql_port" $OPTIONS)"
if [[ ${MYSQL_PORT} == "null" ]]; then 
	MYSQL_PORT="3306"
	MYSQL_FULL_HOST="${MYSQL_HOST}"
else
	MYSQL_FULL_HOST="${MYSQL_HOST}:${MYSQL_PORT}"
fi
CLIENT_ID="$(jq -r ".client_id" $OPTIONS)"
CLIENT_SECRET="$(jq -r ".client_secret" $OPTIONS)"
DISCOVERY="$(jq -r ".discovery" $OPTIONS)"
CONTAINER_TIMEZONE="$(jq -r ".container_timezone" $OPTIONS)"
CONFIG_DIR="/config/tmall-bot-x1"
HTTPD_LOG="$(jq -r ".httpd_log" $OPTIONS)"
HTTPD_ERROR_LOG="$(jq -r ".httpd_error_log" $OPTIONS)"


# Set the timezone. Base image does not contain the setup-timezone script, so an alternate way is used.
if [[ "${CONTAINER_TIMEZONE}" == "null" ]]; then
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
	echo "Asia/Shanghai" >  /etc/timezone && \
	echo "[INFO] Container timezone set to: Asia/Shanghai"
else
    cp /usr/share/zoneinfo/${CONTAINER_TIMEZONE} /etc/localtime && \
	echo "${CONTAINER_TIMEZONE}" >  /etc/timezone && \
	echo "[INFO] Container timezone set to: ${CONTAINER_TIMEZONE}"
fi


# Set local databases
LOCAL_MYSQL="$(jq -r ".local_mysql" $OPTIONS)"
if [[ "${LOCAL_MYSQL}" == "true" ]]; then
	MYSQL_HOST="localhost"
	MYSQL_DB_NAME="tmall"
	MYSQL_USER="tmall"
	MYSQL_PASSWD="tmall"
	LOGIN_HOST="localhost"
	MYSQL_FULL_HOST="localhost"
	MARIADB_DATA="/data/databases"
	# Init mariadb
	if [ ! -d "$MARIADB_DATA" ]; then
		echo "[INFO] Create a new mariadb initial system"
		mysql_install_db --user=root --datadir="$MARIADB_DATA" > /dev/null
	else
		echo "[INFO] Use exists mariadb initial system"
	fi

	# Start mariadb
	echo "[INFO] Start MariaDB"
	mysqld_safe --datadir="$MARIADB_DATA" --user=root --skip-log-bin < /dev/null &
	MARIADB_PID=$!

	# Wait until DB is running
	while ! mysql -e "" 2> /dev/null; do
	    sleep 1
	done

	# Init databases
	echo "[INFO] Init tmall database"
    mysql -e "CREATE DATABASE ${MYSQL_DB_NAME};" 2> /dev/null || true

    # Init logins
    if mysql -e "SET PASSWORD FOR '${MYSQL_USER}'@'${LOGIN_HOST}' = PASSWORD('${MYSQL_PASSWD}');" 2> /dev/null; then
        echo "[INFO] Update user ${MYSQL_USER}"
    else
        echo "[INFO] Create user ${MYSQL_USER}"
        mysql -e "CREATE USER '${MYSQL_USER}'@'${LOGIN_HOST}' IDENTIFIED BY '${MYSQL_PASSWD}';" 2> /dev/null || true
    fi

    # Init rights
    echo "[INFO] Alter rights for ${MYSQL_USER}@${LOGIN_HOST} - ${MYSQL_DB_NAME}"
    mysql -e "GRANT ALL PRIVILEGES ON ${MYSQL_DB_NAME}.* TO '${MYSQL_USER}'@'${LOGIN_HOST}';" 2> /dev/null || true

	# Register stop
	function stop_mariadb() {
	    mysqladmin shutdown
	}
	trap "stop_mariadb" SIGTERM SIGHUP
fi

# Tmall databases initialization
MYSQL="mysql -h"${MYSQL_HOST}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWD}" -P"${MYSQL_PORT}" --default-character-set=utf8 -A"
echo "[INFO] Show database:"
echo "----------------------------------------------------------------"
RESULT="$($MYSQL -e "SHOW DATABASES" | grep ${MYSQL_DB_NAME})" 
if [[ ${RESULT} == ${MYSQL_DB_NAME} ]]; then
	$MYSQL -e "SHOW DATABASES"
	echo  "[INFO] Find the database ${RESULT}"
else
	$MYSQL -e "SHOW DATABASES"
	echo "[ERROR] ${MYSQL_DB_NAME} database not found.Please check MYSQL_DB_NAME options or create a database and then runing again."
	exit 1
fi
echo "----------------------------------------------------------------"
echo "[INFO] Show tmall tables and oauth_clients table:"
echo "----------------------------------------------------------------"
MYSQL_DB_TMALL="mysql -h"${MYSQL_HOST}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWD}" -P"${MYSQL_PORT}" -D"${MYSQL_DB_NAME}" --default-character-set=utf8 -A"
TMALL_DB_TABLES="$(${MYSQL_DB_TMALL} -N -e "show tables")"
if [[ "${TMALL_DB_TABLES}" == "" ]]; then
	echo "[INFO] Did not find any table"
	echo "[INFO] Tmall databases initialization....."
	sed -i "s/%%{CLIENT_ID}%%/${CLIENT_ID}/" /bootstrap/tmall-bot-x1/tmallx1.sql
	sed -i "s/%%{CLIENT_SECRET}%%/${CLIENT_SECRET}/" /bootstrap/tmall-bot-x1/tmallx1.sql
	${MYSQL} ${MYSQL_DB_NAME} < /bootstrap/tmall-bot-x1/tmallx1.sql
	${MYSQL_DB_TMALL} -e "
		show tables;
		select * from oauth_clients"
	echo "[INFO] Done"
else
	RESULT="$(${MYSQL_DB_TMALL} -N -e "select * from oauth_clients")"
	DB_CLIENT_ID="$(echo "${RESULT}" | awk '{print $1}')"
	DB_CLIENT_SECRET="$(echo "${RESULT}" | awk '{print $2}')"
	if [[ "${DB_CLIENT_ID}" != "${CLIENT_ID}" ]] || [[ "${DB_CLIENT_SECRET}" != "${CLIENT_SECRET}" ]]; then
		echo "[INFO] update oauth_clients......"
		${MYSQL_DB_TMALL} -e "
			UPDATE oauth_clients
			SET client_id=\"${CLIENT_ID}\",client_secret=\"${CLIENT_SECRET}\"
			WHERE client_id=\"${DB_CLIENT_ID}\" AND client_secret=\"${DB_CLIENT_SECRET}\"
		"
	fi
	$MYSQL_DB_TMALL -e "
	show tables;
	select * from oauth_clients order by redirect_uri"
fi
echo "----------------------------------------------------------------"

# Tmall Bot Install
if [[ ! -d "${CONFIG_DIR}" ]]; then
	echo "[INFO] Tmall Bot Bridge install to the config"
	cp -R /bootstrap/tmall-bot-x1 ${CONFIG_DIR:0:8}
	rm -f "${CONFIG_DIR}/tmallx1.sql"
	sed -i "s#%%{HOMEASSISTANT_URL}%%#${HA_URL}#" ${CONFIG_DIR}/homeassistant_conf.php
	sed -i "s#%%{YOURHOMEASSITANTPASSWORD}%%#${HA_PASSWD}#" ${CONFIG_DIR}/homeassistant_conf.php
	sed -i "s#%%{YOURHOMEASSITANTPASSWORD}%%#${HA_PASSWD}#" ${CONFIG_DIR}/homeassistant_conf.php
	sed -i "s#%%{MYSQL_DB_NAME}%%#${MYSQL_DB_NAME}#" ${CONFIG_DIR}/server.php
	sed -i "s#%%{MYSQL_HOST}%%#${MYSQL_FULL_HOST}#" ${CONFIG_DIR}/server.php
	sed -i "s#%%{MYSQL_USER}%%#${MYSQL_USER}#" ${CONFIG_DIR}/server.php
	sed -i "s#%%{MYSQL_PASSWD}%%#${MYSQL_PASSWD}#" ${CONFIG_DIR}/server.php
	sed -i "s#%%{MYSQL_DB_NAME}%%#${MYSQL_DB_NAME}#" ${CONFIG_DIR}/device/service.php
	sed -i "s#%%{MYSQL_HOST}%%#${MYSQL_FULL_HOST}#" ${CONFIG_DIR}/device/service.php
	sed -i "s#%%{MYSQL_USER}%%#${MYSQL_USER}#" ${CONFIG_DIR}/device/service.php
	sed -i "s#%%{MYSQL_PASSWD}%%#${MYSQL_PASSWD}#" ${CONFIG_DIR}/device/service.php
	echo "[INFO] Done"
fi

PHP_HA_PASSWD="$(grep -e "PASS=\".*\";" ${CONFIG_DIR}/homeassistant_conf.php |awk -F '"' '{print $2}')"
if [[ "${PHP_HA_PASSWD}" != "${HA_PASSWD}" ]]; then
	sed -i "s#${PHP_HA_PASSWD}#${HA_PASSWD}#" ${CONFIG_DIR}/homeassistant_conf.php
fi

# run php-fpm
if [[ "${DISCOVERY}" == "true" ]] && [[ ! -d "${CONFIG_DIR}/device" ]] ; then
	cp -R /bootstrap/tmall-bot-x1/device ${CONFIG_DIR}
elif [[ "${DISCOVERY}" == "false" ]] && [[ -d "${CONFIG_DIR}/device" ]]; then
	rm -rf "${CONFIG_DIR}/device"
fi
php-fpm

# Set access control
DEVICE_USER="$(jq -r ".device_user" $OPTIONS)"
DEVICE_PASSWD="$(jq -r ".device_passwd" $OPTIONS)"
if [[ "DEVICE_USER" == "null" ]] || [[ "DEVICE_PASSWD" == "null" ]] ; then
	echo "[ERROR] device_user and device_passwd can not be empty"
else
	htpasswd -b -c /etc/nginx/auth_conf ${DEVICE_USER} ${DEVICE_PASSWD}
fi

# Nginx Log
if [[ "${HTTPD_LOG}" == "true" ]]; then
	echo "[INFO] Enable Nginx log"
	echo "" > /var/log/nginx/tmall.access.log
	tail -f /var/log/nginx/tmall.access.log &
fi
if [[ "${HTTPD_ERROR_LOG}" == "true" ]]; then
	echo "[INFO] Enable Nginx error log"
	echo "" > /var/log/nginx/tmall.error.log
	tail -f /var/log/nginx/tmall.error.log &
fi

# Select HTTP mode
SSL_ARRAY=$(jq -r ".ssl | length " ${OPTIONS})
if [[ ${SSL_ARRAY} -eq 1 ]]; then
	SSL_TRUSTED_CERTIFICATE="$(jq -r ".ssl[0].ssl_trusted_certificate" ${OPTIONS})"
	SSL_CERTIFICATE="$(jq -r ".ssl[0].ssl_certificate" ${OPTIONS})"
	SSL_KEY="$(jq -r ".ssl[0].ssl_key" ${OPTIONS})"
	if [[ "${SSL_TRUSTED_CERTIFICATE}" == "null" ]] || [[ "${SSL_CERTIFICATE}" == "null" ]] || [[ "${SSL_KEY}" == "null" ]] ; then
		echo "[ERROR] SSL configuration error, check options."
		echo "SSL_TRUSTED_CERTIFICATE = $SSL_TRUSTED_CERTIFICATE"
	    echo "SSL_CERTIFICATE = $SSL_CERTIFICATE"
	    echo "SSL_KEY = $SSL_KEY"
		exit 1
    elif [ ! -e /data/dhparam.pem ]; then
        openssl dhparam -dsaparam -out /data/dhparam.pem 4096
    fi
    sed -i "s#%%{SSL_TRUSTED_CERTIFICATE}%%#${SSL_TRUSTED_CERTIFICATE}#" /bootstrap/config/nginx/https.conf
    sed -i "s#%%{SSL_CERTIFICATE}%%#${SSL_CERTIFICATE}#" /bootstrap/config/nginx/https.conf
    sed -i "s#%%{SSL_KEY}%%#${SSL_KEY}#" /bootstrap/config/nginx/https.conf
	cp /bootstrap/config/nginx/https.conf /etc/nginx/conf.d/default.conf
else
	cp /bootstrap/config/nginx/http.conf /etc/nginx/conf.d/default.conf
fi
echo "[INFO] Clearing any old processes..."
rm -f /run/nginx/nginx.pid
echo "[INFO] Starting Nginx..."
nginx -g "daemon off;"