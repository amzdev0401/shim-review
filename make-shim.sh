#!/bin/sh
set -e

echo "Building Docker image..."
docker build --no-cache -t shim-build .

echo "Creating temporary container instance..."
docker create --name temp-shim-container shim-build

echo "Extracting shimx64.efi..."
docker cp temp-shim-container:/opt/shim-16.1/shimx64.efi ./

echo "Cleaning up temporary container..."
docker rm temp-shim-container

echo "Done! shimx64.efi successfully extracted to current directory."
