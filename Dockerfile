# run "docker pull ubuntu:jammy" before building. 
FROM ubuntu:jammy

RUN sed -i 's/# deb-src/deb-src/' /etc/apt/sources.list && \
    apt update -y && \
    DEBIAN_FRONTEND=noninteractive apt install -y devscripts git-buildpackage software-properties-common && \
    apt build-dep -y shim tar wget git curl bsdmainutils wget dos2unix build-essential 
LABEL MAINTAINER AmZetta Technologies <sales@amzetta.com>

LABEL VERSION ="1.0"
LABEL DESCRIPTION ="Docker Image To build Shim 16.1 for AmZetta Technologies."

# Get source code from git and copy certificate and SBAT file
WORKDIR /opt
RUN curl -L -O https://github.com/rhboot/shim/releases/download/16.1/shim-16.1.tar.bz2
RUN tar -xvjf shim-16.1.tar.bz2
WORKDIR /opt/shim-16.1

# Copy patch and other binaries to docker
COPY sbat.amzetta.csv /opt/shim-16.1/data
COPY amzetta.der /opt/shim-16.1/
COPY shimx64.efi /opt/shim-16.1/

# Collect original SHIM data
RUN objdump -s -j .sbat shimx64.efi
RUN objdump -s -j .sbat shimx64.efi > original_sbatdump
RUN objdump -s -j .sbatlevel shimx64.efi > original_sbatlevel
RUN sha256sum shimx64.efi > original_shim_hash
RUN hexdump -Cv shimx64.efi > original_shim_hexdump

RUN cp shimx64.efi shimx64.efi.orig 

# Build the Amzetta SHIM from scratch
RUN make VENDOR_CERT_FILE=amzetta.der

# Collect compiled SHIM data
RUN objdump -s -j .sbat shimx64.efi
RUN objdump -s -j .sbat shimx64.efi > builded_sbatdump
RUN objdump -s -j .sbatlevel shimx64.efi > builded_sbatlevel
RUN sha256sum shimx64.efi > builded_shim_hash
RUN hexdump -Cv shimx64.efi > builded_shim_hexdump

# Display hash builded shim and original shim
RUN cat builded_shim_hash
RUN cat original_shim_hash

# Display sbat level builded shim and original shim
RUN cat builded_sbatlevel
RUN cat original_sbatlevel

# Compare the SHIM content 
RUN diff builded_shim_hash original_shim_hash
RUN diff builded_shim_hexdump original_shim_hexdump
RUN diff builded_sbatdump original_sbatdump
RUN diff builded_sbatlevel original_sbatlevel
