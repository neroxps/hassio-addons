#!/bin/bash
options="/data/options.json"
cmd_num=$(jq -r '.cmd | length' $options)

for (( i = 0; i < $cmd_num; i++ )); do
	bash -c "$(jq -r ".cmd[$i]" $options)"
done