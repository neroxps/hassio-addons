#!/bin/bash
OPTIONS="/data/options.json"
if [[ "$(jq -r ".debug" $OPTIONS)" == "true" ]]; then
    set -x
fi
if [[ -z HA_URL ]]; then
    HA_URL="http://hassio/homeassistant"
fi
if [[ -z HA_PASSWD ]]; then
    HA_PASSWD="${HASSIO_TOKEN}"
fi
MYSQL_HOST="$(jq -r ".remote_database.mysql_host" $OPTIONS)"
MYSQL_DB_NAME="$(jq -r ".remote_database.mysql_db_name" $OPTIONS)"
MYSQL_USER="$(jq -r ".remote_database.mysql_user" $OPTIONS)"
MYSQL_PASSWD="$(jq -r ".remote_database.mysql_passwd" $OPTIONS)"
MYSQL_PORT="$(jq -r ".remote_database.mysql_port" $OPTIONS)"
if [[ ${MYSQL_PORT} == "null" ]]; then 
    MYSQL_PORT="3306"
    MYSQL_FULL_HOST="${MYSQL_HOST}"
else
    MYSQL_FULL_HOST="${MYSQL_HOST}:${MYSQL_PORT}"
fi
CLIENT_ID="$(jq -r ".client_id" $OPTIONS)"
CLIENT_SECRET="$(jq -r ".client_secret" $OPTIONS)"
CONTAINER_TIMEZONE="$(jq -r ".container_timezone" $OPTIONS)"
HTTPD_LOG="$(jq -r ".httpd_log" $OPTIONS)"
HTTPD_ERROR_LOG="$(jq -r ".httpd_error_log" $OPTIONS)"
CONFIG_DIR_TO_CONFIG="$(jq -r ".config_dir_to_config" $OPTIONS)"
ADDONS_VERSION=$(curl -X GET -H "X-HASSIO-KEY:$HASSIO_TOKEN" 'http://hassio/addons/85b28355_tmall-bot-x1/info' | jq -r '.data.version')
if [[ ${CONFIG_DIR_TO_CONFIG} == "true" ]]; then
    CONFIG_DIR="/config/tmall-bot-x1"
    LOCAL_ADDONS_VERSION=$(cat ${CONFIG_DIR}/addons_version 2> /dev/null)
else
    CONFIG_DIR="/data/tmall-bot-x1"
fi



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
LOCAL_MYSQL=$(jq -r ".remote_database | length " ${OPTIONS})
if [[ ${LOCAL_MYSQL} -eq 0 ]]; then
    echo "[INFO] No remote database found. Will use the local database."
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
else
    REMOTE_DATABASE_VALUE=(${MYSQL_HOST} ${MYSQL_DB_NAME} ${MYSQL_USER} ${MYSQL_PASSWD})
    REMOTE_DATABASE=("MYSQL_HOST" "MYSQL_DB_NAME" "MYSQL_USER" "MYSQL_PASSWD")
    VALUE_NUM=${#REMOTE_DATABASE_VALUE[@]}
    while [[ ${VALUE_NUM} -ge 0 ]]; do
        let VALUE_NUM--
        if [[ "${REMOTE_DATABASE_VALUE[${VALUE_NUM}]}" == "null" ]]; then
            echo "[ERROR] ${REMOTE_DATABASE[${VALUE_NUM}]} can not be empty!"
            exit 1
        fi
    done
    echo "[INFO] Found remote database: ${MYSQL_HOST}"
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
    sed -i "s/%%{CLIENT_ID}%%/${CLIENT_ID}/" /bootstrap/tmallx1.sql
    sed -i "s/%%{CLIENT_SECRET}%%/${CLIENT_SECRET}/" /bootstrap/tmallx1.sql
    sed -i "s/%%{HA_PASSWD}%%/${HASSIO_TOKEN}/" /bootstrap/tmallx1.sql
    ${MYSQL} ${MYSQL_DB_NAME} < /bootstrap/tmallx1.sql
    ${MYSQL_DB_TMALL} -e "
        show tables;
        select * from oauth_clients"
    echo "[INFO] Done"
else
    # Check user_data
    if ! ${MYSQL_DB_TMALL} -e 'show tables' | grep user_data > /dev/null 2>&1 ;then
        echo '[INFO] Table not found user_data'
        printf '[INFO] Update database...............'
        ${MYSQL_DB_TMALL} -e "
            CREATE TABLE user_data (
                id bigint NOT NULL AUTO_INCREMENT,
                user_id VARCHAR(255) NOT NULL,
                homeassistantURL VARCHAR(255) NOT NULL,
                homeassistantPASS VARCHAR(255) NOT NULL,
                user_name VARCHAR(255) NOT NULL,
                email VARCHAR(255),
                expires TIMESTAMP NOT NULL,
                fromwhere VARCHAR(20) NOT NULL,
                PRIMARY KEY (id),
                UNIQUE inx_user_id (user_id)
            );
            INSERT INTO \`user_data\`
            VALUES (1, 'user001', 'http://hassio/homeassistant', '${HASSIO_TOKEN}', '个人用户'
                , 'email@email.com', '2018-06-02 14:44:00', 'c1pher-git');
			alter table oauth_devices add column user_id VARCHAR(255);
			UPDATE oauth_devices SET user_id='user001';
            UPDATE oauth_access_tokens SET user_id='user001';
            UPDATE oauth_refresh_tokens SET user_id='user001';
			UPDATE oauth_authorization_codes SET user_id='user001'" >> /tmp/update.log 2>&1
        if [[ $? -eq 0 ]];then
            printf 'Done\n'
        else
            printf 'Error\n'
            echo 'Please check the user_data table in the database'
            $MYSQL -e "SHOW DATABASES"
            cat /tmp/update.log
            exit 1
        fi
    fi

    # Update client_id and client_secret
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
    ${MYSQL_DB_TMALL} -e "
        show tables;
        select * from oauth_clients order by redirect_uri"
fi
echo "----------------------------------------------------------------"

# Update ha_url and passwd from HASSIO_TOKEN.
RESULT=$(${MYSQL_DB_TMALL} -N -e 'select * from user_data' | sed -n '2p')
DB_HASSIO_TOKEN=$(echo $RESULT | awk '{print $4}')
if [[ "${HASSIO_TOKEN}" != "${DB_HASSIO_TOKEN}" ]]; then
    ${MYSQL_DB_TMALL} -e "
        UPDATE user_data
        SET homeassistantPASS=\"${HASSIO_TOKEN}\"
        WHERE id=1
    "
fi
        
# Chack upgrade 4.0
COLUMN_DEVICES="$(${MYSQL_DB_TMALL} -N -e "select  COLUMN_NAME from information_schema.columns where table_schema =\"${MYSQL_DB_NAME}\" and table_name = 'oauth_devices' and COLUMN_NAME = 'devices'")"
COLUMN_VIRTUAL="$(${MYSQL_DB_TMALL} -N -e "select  COLUMN_NAME from information_schema.columns where table_schema =\"${MYSQL_DB_NAME}\" and table_name = 'oauth_devices' and COLUMN_NAME = 'virtual'")"
COLUMN_ZONE="$(${MYSQL_DB_TMALL} -N -e "select  COLUMN_NAME from information_schema.columns where table_schema =\"${MYSQL_DB_NAME}\" and table_name = 'oauth_devices' and COLUMN_NAME = 'zone'")"
function rm_config() {
    if [[ -d "${CONFIG_DIR}" ]]; then
        rm -rf "${CONFIG_DIR}"
    fi
}
if [[ "${COLUMN_DEVICES}" == "" ]]; then
    rm_config
    ${MYSQL_DB_TMALL} -e "ALTER TABLE  \`oauth_devices\` ADD  \`devices\` TEXT NOT NULL AFTER  \`jsonData\`"
fi
if [[ "${COLUMN_VIRTUAL}" == "" ]]; then
    rm_config
    ${MYSQL_DB_TMALL} -e "ALTER TABLE \`oauth_devices\` ADD \`virtual\` INT NOT NULL DEFAULT "0" AFTER \`jsonData\`"
fi
if [[ "${COLUMN_ZONE}" == "" ]]; then
    rm_config
    ${MYSQL_DB_TMALL} -e "ALTER TABLE \`oauth_devices\` ADD \`zone\` VARCHAR( 255 ) NOT NULL AFTER \`devices\`"
fi

# Check Tmall-bot-x1 addon version
if [[ ${CONFIG_DIR_TO_CONFIG} ]] && [[ -z ${LOCAL_ADDONS_VERSION} ]] && [[ "${LOCAL_ADDONS_VERSION}" != "${ADDONS_VERSION}" ]] ; then
	if [[ -z ${LOCAL_ADDONS_VERSION} ]]; then
		LOCAL_ADDONS_VERSION='old'
	fi
	mv /config/tmall-bot-x1 /config/tmall-bot-x1-${LOCAL_ADDONS_VERSION}
fi

# Tmall Bot Install
if [[ ! -d "${CONFIG_DIR}" ]]; then
    echo "[INFO] Tmall Bot Bridge install to the ${CONFIG_DIR}"
    cp -R /bootstrap/tmall-bot-x1 ${CONFIG_DIR%/*}
    echo ${ADDONS_VERSION} > ${CONFIG_DIR}/addons_version
    echo "[INFO] Tmall Bot Bridge installation completed!"
fi

# Update homeassistant_conf.php
#
# The c1pher-cn version puts the URL and PASS in the database.
# sed -i "s#const URL=.*#const URL=\"${HA_URL}\";#" ${CONFIG_DIR}/homeassistant_conf.php
# sed -i "s#const PASS=.*#const PASS=\"${HA_PASSWD}\";#" ${CONFIG_DIR}/homeassistant_conf.php
#
sed -i "s#const DBNAME.*#const DBNAME=\"mysql:dbname=${MYSQL_DB_NAME};host=${MYSQL_HOST}\";#" ${CONFIG_DIR}/homeassistant_conf.php
sed -i "s#const DBUSER.*#const DBUSER=\"${MYSQL_USER}\";#" ${CONFIG_DIR}/homeassistant_conf.php
sed -i "s#const DBPASS.*#const DBPASS=\"${MYSQL_PASSWD}\";#" ${CONFIG_DIR}/homeassistant_conf.php
echo "[INFO] Update homeassistant_conf.php completed!"
sed -n "/^const/p" ${CONFIG_DIR}/homeassistant_conf.php

# run php-fpm
php-fpm

# Set access control
DEVICE_USER="$(jq -r ".device_user" $OPTIONS)"
DEVICE_PASSWD="$(jq -r ".device_passwd" $OPTIONS)"
if [[ "${DEVICE_USER}" == "null" ]] || [[ "${DEVICE_USER}" == "null" ]] ; then
    echo "[INFO] DEVICE_USER and DEVICE_PASSWD settings not found, the system automatically generates a password."
    DEVICE_USER="admin"
    DEVICE_PASSWD="$(tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1)"
    htpasswd -b -c /etc/nginx/auth_conf ${DEVICE_USER} ${DEVICE_PASSWD}
else
    htpasswd -b -c /etc/nginx/auth_conf ${DEVICE_USER} ${DEVICE_PASSWD}
fi
echo "Device Remote Access:"
echo "USERNAME:${DEVICE_USER}"
echo "PASSWORD:${DEVICE_PASSWD}"

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

# Select web mode
SSL_ARRAY=$(jq -r ".ssl | length " ${OPTIONS})
sed -i "s#%%{ROOT_DIR}%%#${CONFIG_DIR}#" /bootstrap/config/nginx/*.conf
if [[ ${SSL_ARRAY} -eq 3 ]]; then
    echo "[INFO] Enable Https mode"
    SSL_TRUSTED_CERTIFICATE="$(jq -r ".ssl.ssl_trusted_certificate" ${OPTIONS})"
    SSL_CERTIFICATE="$(jq -r ".ssl.ssl_certificate" ${OPTIONS})"
    SSL_KEY="$(jq -r ".ssl.ssl_key" ${OPTIONS})"
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
    echo "[INFO] Enable Http mode"
    cp /bootstrap/config/nginx/http.conf /etc/nginx/conf.d/default.conf
fi

#RUN
echo "[INFO] Clearing any old processes..."
rm -f /run/nginx/nginx.pid
echo "[INFO] Starting Nginx..."
nginx -g "daemon off;"
