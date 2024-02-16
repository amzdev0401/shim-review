#!/bin/sh
docker build --progress=plain --no-cache -t shim-build .
docker run shim-build
ID=$(docker ps -a | grep shim-build | awk '{print $1;}')
docker cp $ID:/opt/shim-15.8/shimx64.efi ./

