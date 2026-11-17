#!/bin/bash

# Build security-patched GRUB 2.11 x86_64 EFI for AmZetta SnapOS
#
# Baseline:
#   65bc45963014773e2062ccc63ff34a089d2e352e
#
# Targeted security fixes:
#   CVE-2023-4693
#   CVE-2024-45774
#   CVE-2024-45776
#   CVE-2024-45777
#   CVE-2024-45783
#   CVE-2025-0624
#
# Run this script from its parent directory.
# GRUB source will be cloned into ./grub2.

set -Eeuo pipefail
set -x

# --------------------------------------------------
# Configuration
# --------------------------------------------------

GRUB_REPO="https://github.com/rhboot/grub2.git"

GRUB_COMMIT="65bc45963014773e2062ccc63ff34a089d2e352e"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
GRUB_SRC="$SCRIPT_DIR/grub2"
GFLD="$GRUB_SRC/output"

# --------------------------------------------------
# Security patch definitions
# --------------------------------------------------

# These are upstream abbreviated commit IDs.
# Resolve them to full commit hashes after fetching origin/master.

SECURITY_PATCHES=(
    "0ed2458cc4eff6d9a9199527e2a0b6d445802f94" # CVE-2023-4693
    "ea703528a"                                # grub_strlcpy prerequisite
    "2c34af908"                                # CVE-2024-45774 JPEG
    "09bd6eb58"                                # CVE-2024-45776 gettext
    "b970a5ed9"                                # CVE-2024-45777 gettext
    "f7c070a2e"                                # CVE-2024-45783 HFS+
    "5eef88152"                                # CVE-2025-0624 network
)

# --------------------------------------------------
# Step 1: Clone GRUB source
# --------------------------------------------------

if [[ -e "$GRUB_SRC" ]]; then
    echo "ERROR: $GRUB_SRC already exists."
    echo "Remove or rename the existing directory before running."
    exit 1
fi

git clone "$GRUB_REPO" "$GRUB_SRC"

cd "$GRUB_SRC"

# --------------------------------------------------
# Step 2: Checkout original GRUB commit
# --------------------------------------------------

git checkout --detach "$GRUB_COMMIT"

ACTUAL_COMMIT="$(git rev-parse HEAD)"

if [[ "$ACTUAL_COMMIT" != "$GRUB_COMMIT" ]]; then
    echo "ERROR: Incorrect GRUB baseline commit."
    exit 1
fi

echo "Original GRUB commit: $ACTUAL_COMMIT"

# --------------------------------------------------
# Step 3: Fetch upstream commits from GitHub
# --------------------------------------------------

echo "Fetching GRUB upstream master from GitHub..."

git fetch origin master

# --------------------------------------------------
# Step 4: Create patch manifest
# --------------------------------------------------

PATCH_LOG="$GRUB_SRC/security-patches-applied.txt"

cat > "$PATCH_LOG" <<EOF
AmZetta GRUB 2.11 Security Patch Manifest

Repository:
$GRUB_REPO

Original baseline:
$GRUB_COMMIT

Applied security patches:
EOF

# --------------------------------------------------
# Step 5: Resolve and apply targeted patches
# --------------------------------------------------

apply_security_patch()
{
    local PATCH_ID="$1"
    local PATCH_COMMIT

    echo "========================================"
    echo "Applying security patch: $PATCH_ID"
    echo "========================================"

    # Resolve abbreviated or full commit ID.
    if ! PATCH_COMMIT="$(git rev-parse --verify "${PATCH_ID}^{commit}")"; then
        echo "ERROR: Patch commit not found: $PATCH_ID"
        exit 1
    fi

    echo "Resolved commit: $PATCH_COMMIT"

    # Apply the exact commit.
    git cherry-pick "$PATCH_COMMIT"

    # Record full commit hash.
    echo "$PATCH_COMMIT" >> "$PATCH_LOG"

    echo "Successfully applied: $PATCH_COMMIT"
}

for PATCH in "${SECURITY_PATCHES[@]}"; do
    apply_security_patch "$PATCH"
done

# --------------------------------------------------
# Step 6: Verify security patch history
# --------------------------------------------------

echo "===== SECURITY PATCH HISTORY ====="

git log --oneline -15

echo "===== VERIFY NETWORK FIX ====="

if ! grep -q "config_buf_len" grub-core/net/net.c; then
    echo "ERROR: Expected network buffer-length fix not found."
    exit 1
fi

if ! grep -q "grub_strlcpy" grub-core/net/net.c; then
    echo "ERROR: Expected bounded network copy not found."
    exit 1
fi

echo "Network buffer-length fix verified."

echo "===== VERIFY grub_strlcpy ====="

grep -R -n "grub_strlcpy" grub-core include/grub

echo "===== SECURITY PATCH MANIFEST ====="

cat "$PATCH_LOG"

# --------------------------------------------------
# Step 7: Create SBAT metadata
# --------------------------------------------------

cat > "$GRUB_SRC/sbat.csv" <<'EOF'
sbat,1,SBAT Version,sbat,1,https://github.com/rhboot/shim/blob/main/SBAT.md
grub,5,Free Software Foundation,grub,2.11,https://www.gnu.org/software/grub/
grub.amzetta,1,AmZetta Technologies,grub2,2.11-security,https://amzetta.com/
EOF

# --------------------------------------------------
# Step 8: Bootstrap
# --------------------------------------------------

# --------------------------------------------------
# Step 8: Bootstrap GRUB using GitHub Gnulib mirror
# --------------------------------------------------

GNULIB_REPO="https://github.com/coreutils/gnulib.git"

echo "Configuring Gnulib GitHub mirror..."

# Remove an incomplete Gnulib checkout from a previous failed attempt.
if [[ -d "$GRUB_SRC/gnulib" ]] &&
   ! git -C "$GRUB_SRC/gnulib" rev-parse --verify HEAD >/dev/null 2>&1; then
    echo "Removing incomplete Gnulib checkout..."
    rm -rf "$GRUB_SRC/gnulib"
fi

# Override the Gnulib submodule URL locally.
# This prevents bootstrap from contacting Savannah.
git config submodule.gnulib.url "$GNULIB_REPO"

# Also set the URL used by bootstrap when cloning directly.
export GNULIB_URL="$GNULIB_REPO"

echo "Gnulib repository: $GNULIB_REPO"

# Run bootstrap.
./bootstrap

if [[ ! -d "$GRUB_SRC/gnulib" ]]; then
    echo "ERROR: Gnulib checkout was not created."
    exit 1
fi

echo "Gnulib checkout successful."

git -C "$GRUB_SRC/gnulib" log -1 --oneline


# --------------------------------------------------
# Step 9: Configure GRUB EFI
# --------------------------------------------------

mkdir -p "$GFLD"

./configure \
    --with-platform=efi \
    --target=x86_64 \
    --prefix="$GFLD"

# --------------------------------------------------
# Step 10: Compile
# --------------------------------------------------

make -j"$(nproc)"

# --------------------------------------------------
# Step 11: Install
# --------------------------------------------------

make install

sync

# --------------------------------------------------
# Step 12: Verify build tools and modules
# --------------------------------------------------

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

echo "===== GRUB BUILD VERSION ====="

"$GRUB_MKIMAGE" --version

# --------------------------------------------------
# Step 13: Generate EFI executable
# --------------------------------------------------

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

# --------------------------------------------------
# Step 14: Verify EFI binary
# --------------------------------------------------

EFI_FILE="$GRUB_SRC/grubx64.efi"

if [[ ! -s "$EFI_FILE" ]]; then
    echo "ERROR: EFI image was not generated."
    exit 1
fi

echo "===== EFI FILE INFORMATION ====="

file "$EFI_FILE"
stat -c '%n %s bytes' "$EFI_FILE"
sha256sum "$EFI_FILE"

# --------------------------------------------------
# Step 15: Verify SBAT section
# --------------------------------------------------

echo "===== GRUB EFI SBAT INFORMATION ====="

objdump -s -j .sbat "$EFI_FILE"

# --------------------------------------------------
# Step 16: Save build information
# --------------------------------------------------

{
    echo "GRUB baseline: $GRUB_COMMIT"
    echo "Final source commit: $(git rev-parse HEAD)"
    echo
    echo "GRUB version:"
    "$GRUB_MKIMAGE" --version
    echo
    echo "EFI SHA256:"
    sha256sum "$EFI_FILE"
    echo
    echo "Applied security patches:"
    cat "$PATCH_LOG"
} > "$GRUB_SRC/build-information.txt"

# --------------------------------------------------
# Step 17: Final status
# --------------------------------------------------

echo
echo "=========================================="
echo "GRUB SECURITY BUILD COMPLETED"
echo "=========================================="

echo "Original commit: $GRUB_COMMIT"
echo "Final commit:    $(git rev-parse HEAD)"
echo "GRUB EFI:        $EFI_FILE"
echo "Patch manifest:  $PATCH_LOG"
echo "Build report:    $GRUB_SRC/build-information.txt"

echo
echo "Review the patch manifest and SBAT metadata"
echo "before signing and submitting to SHIM review."

echo "=========================================="
