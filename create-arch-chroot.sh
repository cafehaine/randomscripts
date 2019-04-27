#!/bin/bash
set -e

# TODO:
# - Check for root
# - Add commandline arguments
# - Backup sudoers

#packages=(base base-devel bash-completion git vim)
packages=(base base-devel)
# aur packages must not depend on other aur packages
#aur_packages=(yay-bin)
aur_packages=()
install_root="/tmp/arch-chroot"
script_dir="$( cd "$(dirname "$0")" ; pwd -P )"

set -o errexit

# 1- mount fs
mkdir -p "$install_root"
mount -t tmpfs tmpfs "$install_root"
mkdir -p "$install_root"/_setup

# 2- install packages
pacstrap -c "$install_root" "${packages[@]}"

if [ ${#aur_packages[@]} -ne 0 ]; then

	# 3- clone aur packages
	for pkg in $aur_packages; do
		git clone https://aur.archlinux.org/$pkg.git \
			"$install_root"/_setup/aur_$pkg
	done

	# 4- Copy setup script and run it
	cat > "$install_root"/_setup/setup_script.sh <<EOF
#!/bin/bash
set -e
echo "Entered chroot"

# 1- create temporary user
useradd -m packager

# 2- add user to sudoers
echo "packager ALL=(ALL) NOPASSWD: ALL">>/etc/sudoers

# 3- install aur packages
for dir in /_setup/aur_*; do
	echo "Building \$dir"
	chown -R packager \$dir
	cd "\$dir"
	su packager -c "makepkg -si --noconfirm"
	cd "/"
done

# 4- cleanup
rm -rf /_setup
userdel packager

echo "Exiting chroot"
EOF
	chmod +x "$install_root"/_setup/setup_script.sh
	arch-chroot "$install_root" /_setup/setup_script.sh
fi

# Done !
echo
echo "Done installing!"
echo "To enter the chroot, run 'sudo arch-chroot \"$install_root\"'"
echo "Goodbye!"
