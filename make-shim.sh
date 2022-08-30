#!/bin/sh

docker build --no-cache -t shim-build .
docker run shim-build
ID=$(docker ps -a | grep shim-build | awk '{print $1;}')
docker cp $ID:/opt/shim/shimx64.efi ./

