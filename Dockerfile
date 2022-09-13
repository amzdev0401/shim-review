FROM ubuntu:18.04
LABEL MAINTAINER AmZetta Technologies <sales@amzetta.com>

RUN apt-get update
RUN apt-get install -y build-essential git curl bsdmainutils wget dos2unix

LABEL VERSION ="1.0"
LABEL DESCRIPTION ="Docker Image To build Shim 15.06 for AmZetta Technologies."

# Get source code from git and copy certificate and SBAT file
WORKDIR /opt
RUN git clone --recursive -b 15.6 https://github.com/rhboot/shim.git shim
COPY sbat.amzetta.csv /opt/shim/data
COPY amzetta.der /opt/shim/
COPY shimx64.efi /opt/shim/

WORKDIR /opt/shim

#  Find sha256 sum hexdump
RUN sha256sum shimx64.efi > original_shim_hash
RUN hexdump -Cv shimx64.efi > original_shim_hexdump
RUN cp shimx64.efi shimx64.efi.orig

# Build the  Amzetta SHIM from scratch
RUN make VENDOR_CERT_FILE=amzetta.der
RUN objdump -s -j .sbat shimx64.efi
RUN sha256sum shimx64.efi > builded_shim_hash
RUN hexdump -Cv shimx64.efi > builded_shim_hexdump
RUN cat builded_shim_hash
RUN cat original_shim_hash

# Compare SHIM
RUN diff builded_shim_hash original_shim_hash
RUN diff builded_shim_hexdump original_shim_hexdump
