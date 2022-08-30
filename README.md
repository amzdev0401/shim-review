This repo is for review of requests for signing shim.  To create a request for review:

- clone this repo
- edit the template below
- add the shim.efi to be signed
- add build logs
- add any additional binaries/certificates/SHA256 hashes that may be needed
- commit all of that
- tag it with a tag of the form "myorg-shim-arch-YYYYMMDD"
- push that to github
- file an issue at https://github.com/rhboot/shim-review/issues with a link to your tag
- approval is ready when the "accepted" label is added to your issue

Note that we really only have experience with using GRUB2 on Linux, so asking
us to endorse anything else for signing is going to require some convincing on
your part.

Here's the template:

-------------------------------------------------------------------------------
### What organization or people are asking to have this signed?
-------------------------------------------------------------------------------
AmZetta Technologies  
AmZetta Technologies is a software developer providing secure endpoint solutions for companies and organizations worldwide. https://amzetta.com/products/ztc/

-------------------------------------------------------------------------------
### What product or service is this for?
-------------------------------------------------------------------------------
AmZetta zTC: Thin Client Endpoint Devices for Digital Workspaces, Citrix, Microsoft Hyper-V & WVD, VMware and other VDI and DaaS environments. AmZetta zTC Thin Clients are available in Linux and Windows operating system options and are designed to support all user types from call centers, students, office and remote users, manufacturing and high-end graphics users requiring CAD, HD Video/Audio and more. AmZetta zTC Thin Clients are preinstalled with the SnapOS operating system. The Snap Client Manager (SCM) software manages, monitors, and secures AmZetta zTC Thin Clients and SnapOS deployments from a single intuitive interface. Equip your organization with the agility to adapt without compromising power, compatibility, or security with the AmZetta zTC Thin Client product line. 
For More info: https://amzetta.com/ztc/

-------------------------------------------------------------------------------
### What's the justification that this really does need to be signed for the whole world to be able to boot it?
-------------------------------------------------------------------------------
AmZetta Technologies customers would like to be able to run and deploy the SnapOS operating system without disabling Secure Boot. The customers are seeking a more secure Thin Client solution and want to utilize secure boot. The AmZetta zTC Thin Clients with SnapOS are deployed in financial, healthcare and government organizations that require secure boot as a main feature for added security.

-------------------------------------------------------------------------------
### Who is the primary contact for security updates, etc.?
The security contacts need to be verified before the shim can be accepted. For subsequent requests, contact verification is only necessary if the security contacts or their PGP keys have changed since the last successful verification.

An authorized reviewer will initiate contact verification by sending each security contact a PGP-encrypted email containing random words.
You will be asked to post the contents of these mails in your `shim-review` issue to prove ownership of the email addresses and PGP keys.

-------------------------------------------------------------------------------
- Name:Loganathan Ranganathan
- Position:Engineering Manager III 
- Email address:loganathanr@amzetta.com
- PGP key fingerprint:2A2CF3A69E739955 PGP Key Fingerprint: 1920 A439 96A8 431B 6113 E95A 2A2C F3A6 9E73 9955, HKP key server: https://keyserver.ubuntu.com
- https://keyserver.ubuntu.com/pks/lookup?search=loganathanr%40amzetta.com&fingerprint=on&op=index

(Key should be signed by the other security contacts, pushed to a keyserver
like keyserver.ubuntu.com, and preferably have signatures that are reasonably
well known in the Linux community.)

-------------------------------------------------------------------------------
### Who is the secondary contact for security updates, etc.?
-------------------------------------------------------------------------------
- Name:Justine Bagby
- Position:Director - Sales 
- Email address:Justinb@amzetta.com
- PGP key fingerprint:52D3D8F74C848F3A PGP Key Fingerprint: 87F2 B43A F046 F217 11CB 22AA 52D3 D8F7 4C84 8F3A, HKP key server: https://keyserver.ubuntu.com
- https://keyserver.ubuntu.com/pks/lookup?search=Justinb%40amzetta.com&fingerprint=on&op=index

(Key should be signed by the other security contacts, pushed to a keyserver
like keyserver.ubuntu.com, and preferably have signatures that are reasonably
well known in the Linux community.)

-------------------------------------------------------------------------------
### Were these binaries created from the 15.6 shim release tar?
Please create your shim binaries starting with the 15.6 shim release tar file: https://github.com/rhboot/shim/releases/download/15.6/shim-15.6.tar.bz2

This matches https://github.com/rhboot/shim/releases/tag/15.6 and contains the appropriate gnu-efi source.

-------------------------------------------------------------------------------
Created from https://github.com/rhboot/shim/releases/download/15.6 release.
No added patches.

-------------------------------------------------------------------------------
### URL for a repo that contains the exact code which was built to get this binary:
-------------------------------------------------------------------------------
https://github.com/rhboot/shim.git, tag 15.6

-------------------------------------------------------------------------------
### What patches are being applied and why:
-------------------------------------------------------------------------------
No patches were applied.

-------------------------------------------------------------------------------
### If shim is loading GRUB2 bootloader what exact implementation of Secureboot in GRUB2 do you have? (Either Upstream GRUB2 shim_lock verifier or Downstream RHEL/Fedora/Debian/Canonical-like implementation)
-------------------------------------------------------------------------------
Downstream RHEL/Fedora/Debian/Canonical-like implementation

-------------------------------------------------------------------------------
### If shim is loading GRUB2 bootloader and your previously released shim booted a version of grub affected by any of the CVEs in the July 2020 grub2 CVE list, the March 2021 grub2 CVE list, or the June 7th 2022 grub2 CVE list:
* CVE-2020-14372
* CVE-2020-25632
* CVE-2020-25647
* CVE-2020-27749
* CVE-2020-27779
* CVE-2021-20225
* CVE-2021-20233
* CVE-2020-10713
* CVE-2020-14308
* CVE-2020-14309
* CVE-2020-14310
* CVE-2020-14311
* CVE-2020-15705
* CVE-2021-3418 (if you are shipping the shim_lock module)

* CVE-2021-3695
* CVE-2021-3696
* CVE-2021-3697
* CVE-2022-28733
* CVE-2022-28734
* CVE-2022-28735
* CVE-2022-28736
* CVE-2022-28737

### Were old shims hashes provided to Microsoft for verification and to be added to future DBX updates?
### Does your new chain of trust disallow booting old GRUB2 builds affected by the CVEs?
-------------------------------------------------------------------------------
This is the first time SHIM submission, We are going to use GRUB 2.06 for upcoming product line.

-------------------------------------------------------------------------------
### If your boot chain of trust includes a Linux kernel:
### Is upstream commit [1957a85b0032a81e6482ca4aab883643b8dae06e "efi: Restrict efivar_ssdt_load when the kernel is locked down"](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=1957a85b0032a81e6482ca4aab883643b8dae06e) applied?
### Is upstream commit [75b0cea7bf307f362057cc778efe89af4c615354 "ACPI: configfs: Disallow loading ACPI tables when locked down"](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=75b0cea7bf307f362057cc778efe89af4c615354) applied?
### Is upstream commit [eadb2f47a3ced5c64b23b90fd2a3463f63726066 "lockdown: also lock down previous kgdb use"](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=eadb2f47a3ced5c64b23b90fd2a3463f63726066) applied?

-------------------------------------------------------------------------------
1957a85b0032a81e6482ca4aab883643b8dae06e: Yes
75b0cea7bf307f362057cc778efe89af4c615354: Yes
eadb2f47a3ced5c64b23b90fd2a3463f63726066: No

-------------------------------------------------------------------------------
### If you use vendor_db functionality of providing multiple certificates and/or hashes please briefly describe your certificate setup.
### If there are allow-listed hashes please provide exact binaries for which hashes are created via file sharing service, available in public with anonymous access for verification.
-------------------------------------------------------------------------------
No, We don't use vendor_db functionality

-------------------------------------------------------------------------------
### If you are re-using a previously used (CA) certificate, you will need to add the hashes of the previous GRUB2 binaries exposed to the CVEs to vendor_dbx in shim in order to prevent GRUB2 from being able to chainload those older GRUB2 binaries. If you are changing to a new (CA) certificate, this does not apply.
### Please describe your strategy.
-------------------------------------------------------------------------------
This is the first time SHIM submission, We are going to use GRUB 2.06 for upcoming product line.

-------------------------------------------------------------------------------
### What OS and toolchain must we use to reproduce this build?  Include where to find it, etc.  We're going to try to reproduce your build as closely as possible to verify that it's really a build of the source tree you tell us it is, so these need to be fairly thorough. At the very least include the specific versions of gcc, binutils, and gnu-efi which were used, and where to find those binaries.
### If the shim binaries can't be reproduced using the provided Dockerfile, please explain why that's the case and what the differences would be.
-------------------------------------------------------------------------------
Ubuntu 18.04 or above with Docker, run make-shim.sh

-------------------------------------------------------------------------------
### Which files in this repo are the logs for your build?
This should include logs for creating the buildroots, applying patches, doing the build, creating the archives, etc.

-------------------------------------------------------------------------------
This should include logs for creating the buildroots, applying patches, doing the build, creating the archives, etc.

-------------------------------------------------------------------------------
### What changes were made since your SHIM was last signed?
-------------------------------------------------------------------------------
This is first time submission.

-------------------------------------------------------------------------------
### What is the SHA256 hash of your final SHIM binary?
-------------------------------------------------------------------------------
542fc0eee529c01b65dbdaa279a4d829902a31eded463a898ce430306342ee2d  shimx64.efi

-------------------------------------------------------------------------------
### How do you manage and protect the keys used in your SHIM?
-------------------------------------------------------------------------------
Amzetta Technologies's private key stored in Hardware Security Module(YubiHSM).
Only authorized engineering professional having the access to build the binaries and sigining (SHIM, GRUB2, Linux kernel and SnapOS software)

-------------------------------------------------------------------------------
### Do you use EV certificates as embedded certificates in the SHIM?
-------------------------------------------------------------------------------
Yes

-------------------------------------------------------------------------------
### Do you add a vendor-specific SBAT entry to the SBAT section in each binary that supports SBAT metadata ( grub2, fwupd, fwupdate, shim + all child shim binaries )?
### Please provide exact SBAT entries for all SBAT binaries you are booting or planning to boot directly through shim.
### Where your code is only slightly modified from an upstream vendor's, please also preserve their SBAT entries to simplify revocation.
-------------------------------------------------------------------------------
SHIM:
sbat,1,SBAT Version,sbat,1,https://github.com/rhboot/shim/blob/main/SBAT.md
shim,1,UEFI shim,shim,1,https://github.com/rhboot/shim
shim.amzetta,1,SnapOS,shim,15.6,https://amzetta.com

GRUB:
sbat,1,SBAT Version,sbat,1,https://github.com/rhboot/shim/blob/main/SBAT.md
grub,1,Free Software Foundation,grub,2.06,https://www.gnu.org/software/grub/
grub.amzetta,1,SnapOS,grub2,2.06,https://amzetta.com

-------------------------------------------------------------------------------
### Which modules are built into your signed grub image?
-------------------------------------------------------------------------------
   Original source code has been used without any modification, compiled with only vendor-specific SBAT entry.
   https://ftp.gnu.org/gnu/grub/grub-2.06.tar.gz
    
Modules in signed grub:
all_video boot btrfs cat chain configfile echo efifwsetup efinet ext2 fat font gettext gfxmenu gfxterm gfxterm_background gzio halt hfsplus iso9660 jpeg keystatus loadenv linux lsefi lsefimmap  lssal lvm mdraid09  memdisk minicmd  normal part_apple part_msdos part_gpt password_pbkdf2  reboot search  search_fs_uuid search_fs_file search_label sleep test tftp video xzio lzopio gcry_dsa gcry_sha512 cmp eval true serial hashsum gcry_md5 gcry_rsa



-------------------------------------------------------------------------------
### What is the origin and full version number of your bootloader (GRUB or other)?
-------------------------------------------------------------------------------
curl -O ftp.gnu.org/gnu/grub/grub-2.06.tar.gz

-------------------------------------------------------------------------------
### If your SHIM launches any other components, please provide further details on what is launched.
-------------------------------------------------------------------------------
SHIM only launches signed GRUB

-------------------------------------------------------------------------------
### If your GRUB2 launches any other binaries that are not the Linux kernel in SecureBoot mode, please provide further details on what is launched and how it enforces Secureboot lockdown.
-------------------------------------------------------------------------------
Linux kernel version 5.10 is used, SHIM will only launches signed GRUB AND Kernel, grub verifies signatures on booted kernel.

-------------------------------------------------------------------------------
### How do the launched components prevent execution of unauthenticated code?
-------------------------------------------------------------------------------
Kernel, Grub are updated with latest patch and all are signed with private key to prevent unsigned modules.

-------------------------------------------------------------------------------
### Does your SHIM load any loaders that support loading unsigned kernels (e.g. GRUB)?
-------------------------------------------------------------------------------
No

-------------------------------------------------------------------------------
### What kernel are you using? Which patches does it includes to enforce Secure Boot?
-------------------------------------------------------------------------------
Kernel Version is 5.10, it included enforce secure boot.

-------------------------------------------------------------------------------
### Add any additional information you think we may need to validate this shim.
-------------------------------------------------------------------------------
N/A
