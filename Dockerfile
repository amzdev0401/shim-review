FROM ubuntu:18.04
LABEL MAINTAINER AmZetta Technologies <sales@amzetta.com>

COPY . /build/shim-review-15.6

RUN apt-get update
RUN apt-get install -y build-essential git curl bsdmainutils wget dos2unix

LABEL VERSION ="1.0"
LABEL DESCRIPTION ="Docker Image To build Shim 15.06 for AmZetta Technologies."


WORKDIR /opt
RUN git clone --recursive -b 15.6 https://github.com/rhboot/shim.git shim
WORKDIR /opt/shim

RUN curl -O https://github.com/amzdev0401/shim-review-15.6/AmZetta-shim-x86_64-20220803/loganathanr_pub.as
RUN curl -O https://github.com/amzdev0401/shim-review-15.6/AmZetta-shim-x86_64-20220803/loganathanr_pub.as
RUN curl -O https://github.com/amzdev0401/shim-review-15.6/AmZetta-shim-x86_64-20220803/loganathanr_pub.as






WORKDIR /build
RUN wget https://github.com/rhboot/shim/releases/download/15.6/shim-15.6.tar.bz2
RUN tar xjf shim-15.6.tar.bz2
COPY sbat.amzetta.csv /build/shim-15.6/data

WORKDIR /build/shim-15.6
RUN make VENDOR_CERT_FILE=/build/shim-review-15.6/amzetta.der

WORKDIR /
RUN hexdump -Cv /build/shim-review-15.6/shimx64.efi > shim-orig.hex
RUN hexdump -Cv /build/shim-15.6/shimx64.efi > shim-build.hex
RUN diff -u shim-orig.hex shim-build.hex
RUN sha256sum /build/shim-review-15.6/shimx64.efi
RUN sha256sum /build/shim-15.6/shimx64.efi
