#!/bin/bash

prefix="$1"
target="$2"

params=$(aws ssm get-parameters-by-path \
--path "${prefix}" \
--recursive --with-decryption \
--query "Parameters[*].{Name:Name,Value:Value}" \
--output json)

echo -n "" > $(pwd)/$target

for row in $(echo "${params}" | jq -r '.[] | @base64'); do
    _jq() {
    echo ${row} | base64 --decode | jq -r ${1}
    }
  key_name=$(echo $(_jq '.Name') | sed "s|^${prefix}/||")
  echo ${key_name}=$(echo $(_jq '.Value')) >> $(pwd)/$target
done

if [ $(cat $(pwd)/$target | wc -l) -eq 0 ]; then
  echo "AWS SSM generated file is empty. Exiting with error." && exit 1
fi
