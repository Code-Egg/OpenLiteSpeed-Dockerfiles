#!/usr/bin/env bash


docker build . --tag larshagen/playground:$1 --build-arg OLS_VERSION=$1 --build-arg PHP_VERSION=$2

ID=$(docker run -d -p 80:8088 larshagen/playground:$1)

set -eux 
sleep 1
curl -Ik localhost

docker kill $ID

#docker push larshagen/playground:$1