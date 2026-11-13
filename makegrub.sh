#!/bin/bash

# Build GRUB2 x86_64 EFI for AmZetta SnapOS
# Run this script from the parent directory.
# The script clones GRUB into ./grub2

set -Eeuo pipefail
set -x

GRUB_REPO="https://github.com/rhboot/grub2.git"
GRUB_COMMIT="65bc45963014773e2062ccc63ff34a089d2e352e"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
GRUB_SRC="$SCRIPT_DIR/grub2"

# Step 1: Clone source
if [[ -e "$GRUB_SRC" ]]; then
    echo "ERROR: $GRUB_SRC already exists."
    exit 1
fi

git clone "$GRUB_REPO" "$GRUB_SRC"
cd "$GRUB_SRC"

# Step 2: Checkout exact commit
git reset --hard "$GRUB_COMMIT"

# Verify commit
ACTUAL_COMMIT="$(git rev-parse HEAD)"
if [[ "$ACTUAL_COMMIT" != "$GRUB_COMMIT" ]]; then
    echo "ERROR: Incorrect GRUB commit"
    exit 1
fi

# Step 3: Create SBAT metadata
cat > sbat.csv <<'EOF'
sbat,1,SBAT Version,sbat,1,https://github.com/rhboot/shim/blob/main/SBAT.md
grub,5,Free Software Foundation,grub,2.11,https://www.gnu.org/software/grub/
grub.amzetta,1,AmZetta Technologies,grub2,2.11-65bc45963,https://amzetta.com/
EOF

# Step 4: Bootstrap
./bootstrap

# Step 5: Configure
GFLD="$GRUB_SRC/output"

mkdir -p "$GFLD"

./configure \
    --with-platform=efi \
    --target=x86_64 \
    --prefix="$GFLD"

# Step 6: Compile
make -j"$(nproc)"

# Step 7: Install
make install

sync

# Step 8: Verify build tools and modules
GRUB_MKIMAGE="$GFLD/bin/grub-mkimage"
MODULE_DIR="$GFLD/lib/grub/x86_64-efi"

if [[ ! -x "$GRUB_MKIMAGE" ]]; then
    echo "ERROR: grub-mkimage not found: $GRUB_MKIMAGE"
    exit 1
fi

if [[ ! -d "$MODULE_DIR" ]]; then
    echo "ERROR: GRUB module directory not found: $MODULE_DIR"
    exit 1
fi

# Step 9: Generate EFI executable
"$GRUB_MKIMAGE" \
    -O x86_64-efi \
    -o "$GRUB_SRC/grubx64.efi" \
    -d "$MODULE_DIR" \
    -p /efi/boot \
    --sbat "$GRUB_SRC/sbat.csv" \
    all_video boot btrfs cat chain configfile echo \
    efifwsetup efinet ext2 fat font gettext gfxmenu \
    gfxterm gfxterm_background gzio halt hfsplus \
    iso9660 jpeg keystatus loadenv linux lsefi \
    lsefimmap lssal lvm mdraid09 memdisk minicmd \
    normal part_apple part_msdos part_gpt \
    password_pbkdf2 reboot search search_fs_uuid \
    search_fs_file search_label sleep test tftp video \
    xzio lzopio gcry_dsa gcry_sha512 cmp eval true \
    serial hashsum gcry_md5 gcry_rsa

sync

# Step 10: Verify SBAT section
echo "===== GRUB EFI SBAT INFORMATION ====="

objdump -s -j .sbat "$GRUB_SRC/grubx64.efi"

echo "===== BUILD COMPLETED ====="
echo "GRUB EFI: $GRUB_SRC/grubx64.efi"
echo "GRUB Commit: $ACTUAL_COMMIT"

