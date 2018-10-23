#!/bin/bash
options="/data/options.json"

# 将 json 的 key 作为变量名，value 作为内容，历遍赋值给变量。
keys=$(jq -r '. | keys' ${options} | sed 's/\[\|\]\|\"\|\,//g'| xargs)
for i in $keys;do eval $i=$(jq -r --arg i $i ".$i" ${options}) ;done

/usr/bin/ss-local  \
	-s ${server} \
	-p ${server_port} \
	-b ${local_address} \
	-l ${local_port} \
	-k ${server_password} \
	-m ${encrypt_method} \
	${args}