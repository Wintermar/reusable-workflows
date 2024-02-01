#!/bin/bash

rm -rf .env*

prefix="$1"

params=$(aws ssm get-parameters-by-path \
--path "${prefix}" \
--recursive --with-decryption \
--query "Parameters[*].{Name:Name,Value:Value}" \
--output json)

echo -n "" > .env

for row in $(echo "${params}" | jq -r '.[] | @base64'); do
    _jq() {
    echo ${row} | base64 --decode | jq -r ${1}
    }
  key_name=$(echo $(_jq '.Name') | sed "s|^${prefix}/||")
  echo ${key_name}=$(echo $(_jq '.Value')) >> .env
done