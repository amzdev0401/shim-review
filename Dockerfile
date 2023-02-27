FROM ubuntu:18.04
LABEL MAINTAINER AmZetta Technologies <sales@amzetta.com>

RUN apt-get update
RUN apt-get install -y build-essential git curl bsdmainutils wget dos2unix

LABEL VERSION ="1.0"
LABEL DESCRIPTION ="Docker Image To build Shim 15.07 for AmZetta Technologies."

# Get source code from git and copy certificate and SBAT file
WORKDIR /opt
RUN curl -L -O https://github.com/rhboot/shim/releases/download/15.7/shim-15.7.tar.bz2
RUN tar -xvjf shim-15.7.tar.bz2
WORKDIR /opt/shim-15.7

# Copy patch and other binaries to docker
COPY *.patch /opt/shim-15.7/
RUN git apply 530.patch
COPY sbat.amzetta.csv /opt/shim-15.7/data
COPY amzetta.der /opt/shim-15.7/
COPY shimx64.efi /opt/shim-15.7/

# Collect original SHIM data
RUN objdump -s -j .sbat shimx64.efi
RUN objdump -s -j .sbat shimx64.efi > original_sbatdump
RUN sha256sum shimx64.efi > original_shim_hash
RUN hexdump -Cv shimx64.efi > original_shim_hexdump

RUN cp shimx64.efi shimx64.efi.orig 


# Build the Amzetta SHIM from scratch
RUN make VENDOR_CERT_FILE=amzetta.der

# Collect compiled SHIM data
RUN objdump -s -j .sbat shimx64.efi
RUN objdump -s -j .sbat shimx64.efi > builded_sbatdump
RUN sha256sum shimx64.efi > builded_shim_hash
RUN hexdump -Cv shimx64.efi > builded_shim_hexdump

# Display builded shim and original shim
RUN cat builded_shim_hash
RUN cat original_shim_hash

# Compare the SHIM content 
RUN diff builded_shim_hash original_shim_hash
RUN diff builded_shim_hexdump original_shim_hexdump
RUN diff builded_sbatdump original_sbatdump