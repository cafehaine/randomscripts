#!/bin/bash

if [ "$UID" -ne 0 ]; then
	echo "You should run this script as root in a chroot."
	exit 1
fi

which aurman >/dev/null
if [ $? -ne 0 ]; then
	echo "Please install aurman first."
	exit 1
fi

echo
echo "==> WARNING: You should only run this in a clean chroot that you don't mind"
echo "==> wrecking."
echo
echo "Type 'OK.' to continue."

read input
if [ "$input" != "OK." ]; then
	echo "Goodbye"
	exit 0
fi

#-----------#
# Constants #
#-----------#

# pattern to match lines with official packages
RGX_OFF="^(?:\((?!(AUR|aur)).*\))?\*\s\S+$"
# pattern to match lines with aur packages
RGX_AUR="^\((?:(AUR|aur)).*\)\*\s\S+$"
SED_EXT="s/.*\*\ //"

#-----------#
# Functions #
#-----------#

generate_list() {
	cat package_list_* | grep -Po "$1" | sed "$SED_EXT" | sort | uniq
}

check_official_package() {
	pacman -Ss "^$1$">/dev/null
	echo $?
}

check_aur_package() {
	if [ "$(aurman --aur -Ss "^$1$" | wc -l)" -eq 0 ]; then
		echo 1
	else
		echo 0
	fi
}

#--------#
# Script #
#--------#

official_packages=$(generate_list "$RGX_OFF")
aur_packages=$(generate_list "$RGX_AUR")
count_official=$(echo $official_packages | wc -w)
count_aur=$(echo $aur_packages | wc -w)

fail_count=0

echo "- $count_official official packages"
echo "- $count_aur AUR packages"
echo
echo ":: Checking official packages..."

i=1
for p in $official_packages; do
	echo -ne "$i/$count_official\r"
	if [ "$(check_official_package $p)" -ne 0 ]; then
		echo Inexisting package: $p
		let "fail_count +=1 "
	fi
	let "i += 1"
done

echo -e "\n"
echo ":: Checking AUR packages..."

i=1
for p in $aur_packages; do
	echo -ne "$i/$count_aur\r"
	if [ "$(check_aur_package $p)" -ne 0 ]; then
		echo Inexisting package: $p
		let "fail_count +=1 "
	fi
	let "i += 1"
done

echo -e "\n"
echo ":: DONE"

echo "$fail_count failed package(s)"

if [ $fail_count -ne 0 ]; then
	echo "Please fix the errors and run again the script to compile the AUR packages"
	exit 1
fi

echo
echo ":: Compiling AUR packages..."
echo

echo "creating an user and configuring it to build packages..."
useradd -m packager
echo "packager ALL=(ALL) NOPASSWD: ALL">>/etc/sudoers
chown -R packager /export
mkdir -p /export
echo "PKGDEST=/export">/home/packager/.makepkg.conf

echo "compiling packages..."
for p in $aur_packages; do
	su packager -c "aurman --noedit --noconfirm -S $p"
done

