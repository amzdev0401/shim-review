##!/bin/bash
# Run from grub2 folder
# sbat.csv in grub2 folder

# step 1 : git clone https://github.com/rhboot/grub2.git
# step 2 : cd grub2
# step 3 : create sbat.csv
#          sbat,1,SBAT Version,sbat,1,https://github.com/rhboot/shim/blob/main/SBAT.md 
#          grub,4,Free Software Foundation,grub,2.11,https://www.gnu.org/software/grub/ 
#          grub.amzetta,1,AmZetta Technologies,grub2,2.11-65bc45963,https://amzetta.com/
# step 4 : run build script ./makegrub.sh

set -x
PWD=`pwd`


git reset --hard 65bc45963014773e2062ccc63ff34a089d2e352e
./bootstrap
mkdir output
chmod -R 777 output
GFLD="$PWD/output"
./configure --with-platform=efi  --target=x86_64 --prefix=$GFLD
make
make install
sync
GEFI=" $PWD/output/lib/grub/x86_64-efi/ "
./grub-mkimage -O x86_64-efi -o grubx64.efi -d $GEFI -p /efi/boot --sbat sbat.csv all_video boot btrfs cat chain configfile echo efifwsetup efinet ext2 fat font gettext gfxmenu gfxterm gfxterm_background gzio halt hfsplus iso9660 jpeg keystatus loadenv linux lsefi lsefimmap lssal lvm mdraid09 memdisk minicmd normal part_apple part_msdos part_gpt password_pbkdf2 reboot search search_fs_uuid search_fs_file search_label sleep test tftp video xzio lzopio gcry_dsa gcry_sha512 cmp eval true serial hashsum gcry_md5 gcry_rsa 

objdump -s -j .sbat grubx64.efi 
