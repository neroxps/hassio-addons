#!/bin/bash
set -e
OPTIONS="/data/options.json"
SLEEP_NUM=$(jq --raw-output '.sleep_time' ${OPTIONS})
MQTT_ADDR=$(jq --raw-output '.mqtt_address' ${OPTIONS})
MQTT_USER=$(jq --raw-output '.mqtt_user' ${OPTIONS})
MQTT_PWD=$(jq --raw-output '.mqtt_password' ${OPTIONS})
MQTT_PORT=$(jq --raw-output '.mqtt_port' ${OPTIONS})
MQTT_TOPIC=$(jq --raw-output '.mqtt_topic' ${OPTIONS})
BLUE_LISTS=$(jq --raw-output '.blue_list | length' ${OPTIONS})
declare -a DEV_STATUS
#chack
hcitool dev | grep hci
if [[ $? -ne 0 ]]; then
	echo "No Bluetooth device found, see the guide https://github.com/neroxps/hassio-addons/tree/master/bluetooth_scan_tracker"
elif [[ ${MQTT_PORT} == "null" ]]; then
	MQTT_PORT=1883
elif [[ ${SLEEP_NUM} == "null" ]]; then
	SLEEP_NUM=5
elif [[ ${MQTT_ADDR} == "null" ]]; then
	echo "MQTT_ADDR is empty, see the guide https://github.com/neroxps/hassio-addons/tree/master/bluetooth_scan_tracker"
	exit 1
elif [[ ${MQTT_TOPIC} == "null" ]]; then
	echo "MQTT_TOPIC is empty, see the guide https://github.com/neroxps/hassio-addons/tree/master/bluetooth_scan_tracker"
	exit 1
elif [[ ${BLUE_LISTS} == "null" ]]; then
	echo "BLUE_LISTS is empty, see the guide https://github.com/neroxps/hassio-addons/tree/master/bluetooth_scan_tracker"
	exit 1
fi

#main
while true; do
	for (( i=0; i < "${BLUE_LISTS}"; i++ ));do
		MAC=$(jq --raw-output ".blue_list[${i}].mac" ${OPTIONS})
		NAME=$(jq --raw-output ".blue_list[${i}].name" ${OPTIONS})
		DEV_BD_NAME="$(hcitool name ${MAC})"
		if [[ "${DEV_BD_NAME}" == "" ]]; then
			STATUS="not_home"
			if [[ "${STATUS}" != "${DEV_STATUS[${i}]}" ]]; then
				DEV_STATUS[${i}]=${STATUS}
				mosquitto_pub -h ${MQTT_ADDR} -u ${MQTT_USER} -P ${MQTT_PWD} -p ${MQTT_PORT} -t "${MQTT_TOPIC}/${NAME}" -m leave
				echo "${NAME} ${DEV_STATUS[${i}]}"
			fi
		else
			STATUS="home"
			if [[ "${STATUS}" != "${DEV_STATUS[${i}]}" ]]; then
				DEV_STATUS[${i}]=${STATUS}
				mosquitto_pub -h ${MQTT_ADDR} -u ${MQTT_USER} -P ${MQTT_PWD} -p ${MQTT_PORT} -t "${MQTT_TOPIC}/${NAME}" -m enter
				echo "${NAME} ${DEV_STATUS[${i}]}"
			fi
		fi
	done
	sleep ${SLEEP_NUM}
done
