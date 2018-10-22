#!/bin/bash
OPTIONS="/data/options.json"
if [[ "$(jq -r ".debug" ${OPTIONS})" == "true" ]]; then
    set -x
fi
if [[ "$(jq -r ".netease_cookie" ${OPTIONS})" != "null" ]] && [[ "$(jq -r ".netease_cookie" ${OPTIONS})" != "" ]]; then
	sed -i -e "s/\$netease_cookie = '.*'/\$netease_cookie = 'test2'/" /bootstrap/MKOnlineMusicPlayer/api.php
fi
if [[ "$(jq -r ".https" ${OPTIONS})" == "true" ]]; then
	sed -i -e "s/define(\'HTTPS\', .*);/define(\'HTTPS\', true);/" /bootstrap/MKOnlineMusicPlayer/api.php
else
	sed -i -e "s/define(\'HTTPS\', .*);/define(\'HTTPS\', false);/" /bootstrap/MKOnlineMusicPlayer/api.php
fi
if [[ "$(jq -r ".httpd_error_log" ${OPTIONS})" == "true" ]]; then
    echo "[INFO] Enable Nginx error log"
    echo "" > /var/log/nginx/music.error.log
    tail -f /var/log/nginx/music.error.log &
fi
php-fpm
nginx -g "daemon off;"