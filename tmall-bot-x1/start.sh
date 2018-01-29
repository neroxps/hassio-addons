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
	echo "Container timezone set to: Asia/Shanghai"
else
    cp /usr/share/zoneinfo/${CONTAINER_TIMEZONE} /etc/localtime && \
	echo "${CONTAINER_TIMEZONE}" >  /etc/timezone && \
	echo "Container timezone set to: ${CONTAINER_TIMEZONE}"
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

	wait "$MARIADB_PID"
fi

# Mysql Initialization
echo ""
echo ""
echo "-----------------------------:Databases:---------------------------"
mysql -h"${MYSQL_HOST}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWD}" -P"${MYSQL_PORT}" -e "
show databases;
use ${MYSQL_DB_NAME}
quit"
if [[ $? -ne 0 ]]; then
	echo "${MYSQL_DB_NAME} database not found.Please check MYSQL_DB_NAME options or create a database and then runing again."
	exit 1
fi
echo "--------------------------------------------------------------------"
echo ""
echo ""
echo "-------------------------------:Tables:-----------------------------"
mysql -h"${MYSQL_HOST}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWD}" -P"${MYSQL_PORT}" -e "
use ${MYSQL_DB_NAME};
show tables;
select * from oauth_clients order by redirect_uri;" 2>/dev/null
if [[ $? -ne 0 ]]; then
	echo "Mysql Initialization....."
	sed -i "s/%%{CLIENT_ID}%%/${CLIENT_ID}/" /bootstrap/tmall-bot-x1/tmallx1.sql
	sed -i "s/%%{CLIENT_SECRET}%%/${CLIENT_SECRET}/" /bootstrap/tmall-bot-x1/tmallx1.sql
	mysql -h"${MYSQL_HOST}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWD}" -P"${MYSQL_PORT}" ${MYSQL_DB_NAME} < /bootstrap/tmall-bot-x1/tmallx1.sql
	mysql -h"${MYSQL_HOST}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWD}" -P"${MYSQL_PORT}" -e "
	use ${MYSQL_DB_NAME};
	show tables;
	select * from oauth_clients order by redirect_uri;" 2>/dev/null
	echo "Done"
fi
echo "--------------------------------------------------------------------"

# Tmall Bot Install
if [[ ! -d "${CONFIG_DIR}" ]]; then
	echo "Tmall Bot Bridge install to the config"
	cp -R /bootstrap/tmall-bot-x1 ${CONFIG_DIR:0:8}
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
	echo "Done"
fi

if [[ "${DISCOVERY}" == "true" ]] && [[ ! -d "${CONFIG_DIR}/device" ]] ; then
	cp /bootstrap/tmall-bot-x1/device ${CONFIG_DIR}
elif [[ "${DISCOVERY}" == "false" ]] && [[ -d "${CONFIG_DIR}/device" ]]; then
	rm -rf "${CONFIG_DIR}/device"
fi

# Httpd Log
if [[ "${HTTPD_LOG}" == "true" ]]; then
	echo "Enable httpd log"
	echo "" > /var/log/apache2/access.log
	tail -f /var/log/apache2/access.log &
fi
if [[ "${HTTPD_ERROR_LOG}" == "true" ]]; then
	echo "Enable httpd error log"
	echo "" > /var/log/apache2/error.log
	tail -f /var/log/apache2/error.log &
fi

echo "Clearing any old processes..."
rm -f /run/apache2/apache2.pid
rm -f /run/apache2/httpd.pid

echo "Starting apache..."
httpd -D FOREGROUND