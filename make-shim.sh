#!/bin/sh

docker build --no-cache -t shim-build .
docker run shim-build
ID=$(docker ps -a | grep shim-build | awk '{print $1;}')
docker cp $ID:/build/shim-review-15.6/shimx64.efi ./

