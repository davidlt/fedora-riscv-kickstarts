# Kickstart file for Fedora RISC-V (riscv64) Developer Rawhide

#repo --name="koji-override-0" --baseurl=http://fedora-riscv.tranquillity.se/repos-dist/rawhide/latest/riscv64/

install
text
#reboot
lang en_US.UTF-8
keyboard us
# short hostname still allows DHCP to assign domain name
network --bootproto dhcp --device=link --hostname=stage5
rootpw riscv
firewall --enabled --ssh
timezone --utc America/New_York
selinux --disabled
services --enabled=sshd,NetworkManager,chronyd

bootloader --location=none --disabled

zerombr
clearpart --all --initlabel --disklabel=gpt
part / --fstype="ext4" --size=3968

# Halt the system once configuration has finished.
poweroff

%packages
@core
@buildsys-build

openssh
openssh-server
glibc-langpack-en
lsof
nano
openrdate
chrony
systemd-udev
vim-minimal
neovim
screen
hostname
bind-utils
htop
tmux
strace
pciutils
nfs-utils
ethtool
rsync
hdparm
git
moreutils
rpmdevtools
fedpkg
mailx
mutt
patchutils
%end

%post
# Disable default repositories (not riscv64 in upstream)
dnf config-manager --set-disabled rawhide updates updates-testing fedora fedora-modular fedora-cisco-openh264

# Create Fedora RISC-V repo
cat << EOF > /etc/yum.repos.d/fedora-riscv.repo
[fedora-riscv]
name=Fedora RISC-V
baseurl=http://fedora-riscv.tranquillity.se/repos-dist/rawhide/latest/riscv64/
enabled=1
gpgcheck=0
EOF

# systemd starts serial consoles on /dev/ttyS0 and /dev/hvc0.  The
# only problem is they are the same serial console.  Mask one.
systemctl mask serial-getty@hvc0.service

# setup login message
cat << EOF | tee /etc/issue /etc/issue.net
Welcome to the Fedora/RISC-V stage5 disk image
https://fedoraproject.org/wiki/Architectures/RISC-V

Build date: $(date --utc)

Kernel \r on an \m (\l)

The root password is ‘riscv’.

To install new packages use ‘dnf install ...’

If DNS isn’t working, try editing ‘/etc/yum.repos.d/fedora-riscv.repo’.

For updates and latest information read:
https://fedorapeople.org/groups/risc-v/disk-images/readme.txt

Fedora/RISC-V Koji: http://fedora-riscv.tranquillity.se/koji/
Fedora/RISC-V SCM: http://fedora-riscv.tranquillity.se:3000/
EOF
%end

# EOF
