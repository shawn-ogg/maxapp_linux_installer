#!/bin/sh
#
# Painless installation script for the original Max! Home Automation software.
#
# The Max! software is written in java, but the manufacturer only provides 
# a win and mac os installation package. This script downloads the mac package,
# extracts the java code, adjusts the startup script and provides a .desktop
# file for a seamless desktop environment integration.
#  
# This Max! system is sold by elv. For more infromation see:
# 	- https://www.max-portal.elv.de/
#	- http://www.elv.de/forum/max-funk-heizungsregler-system.html
#
# This script is tested successfully on:
#	- (l)ubuntu 16.04
# - debian 8
#
# License: MIT
# Copyright: Tobias Farrenkopf tf@emptyset.de

##############################
# Global vars

URL="http://www.max-portal.elv.de:8181/downloadELV/MAXApp_ELV.dmg"
MAX_INST_DIR="/opt/MAX_APP"
MAX_DESKTOP_FILE="/usr/share/applications/max-app.desktop"
MOUNTPOINT="/tmp/max_img_$$"

##############################
# Functions

check_program() {
	if ! dpkg-query -W "$1" > /dev/null 2>&1; then
		echo
		echo "Dependency \"$1\" is missing." 
		echo "Should I try to intall it? [y/N]"
		read -r response 
		case $response in 
		[yY][eE][sS]|[yY]) 
			echo "Installing \"$1\"..."
	        	sudo apt-get install "$1" || exit 1
	        	;;
	    	*)
			echo "Dependencies not fulfilled."
			echo "Leaving..."
	        	exit 1
	        	;;
		esac
	fi
}

usage() {
	echo "Usage:"
	echo "	$(basename $0) {--install|--remove}"
	echo
	echo "	--install\tThis will install the MAX! software under ${MAX_INST_DIR}"
	echo "	         \tand creates a max.desktop entry under ${MAX_DESKTOP_FILE}"
	echo
	echo "	--remove \tUninstalls the software and the max.desktop file"
}

dependency_checks() {
	check_program wget
	check_program sudo
	check_program dmg2img
	check_program hfsplus
	check_program icnsutils
	check_program default-jre
}
	
install_maxapp() {
	
	echo
	echo "Downloading the MAX! App..."
	echo
	wget --show-progress -q -O mac.dmg "$URL" 

	echo
	echo "Installing..."
	echo

	dmg2img mac.dmg mac.img >/dev/null
	
	mkdir -p $MOUNTPOINT || exit 1
	
	sudo mkdir -p "$MAX_INST_DIR/icons"
	sudo mount -t hfsplus -o loop mac.img $MOUNTPOINT
	sudo cp -r "${MOUNTPOINT}/MAX!.app/Contents/Java" "$MAX_INST_DIR"
	sudo icns2png -o "${MAX_INST_DIR}/icons" -x "${MOUNTPOINT}/MAX!.app/Contents/Resources/maxicon.icns" >/dev/null
	sudo umount "$MOUNTPOINT"
	
	rmdir $MOUNTPOINT
	
	sudo tee "${MAX_INST_DIR}/start.sh" >/dev/null <<EOF
#!/bin/sh
cd ${MAX_INST_DIR}/Java
java -jar MaxLocalApp.jar
EOF

	sudo chmod 755 "${MAX_INST_DIR}/Java/webapp"
	sudo chmod +x "${MAX_INST_DIR}/start.sh"
	
	sudo tee "$MAX_DESKTOP_FILE" >/dev/null <<EOF
[Desktop Entry]
Name=MAX App
Name[de]=MAX App
Comment=MAX Software
Comment[de]=MAX Software
Exec=${MAX_INST_DIR}/start.sh
Icon=${MAX_INST_DIR}/icons/maxicon_32x32x32.png
Terminal=false
Type=Application
StartupNotify=false
Categories=Utility;
EOF
}

remove_maxapp() {
	echo
	echo "Removing the MAX! App.."
	echo
	sudo rm -rf "$MAX_INST_DIR"
	sudo rm -f "$MAX_DESKTOP_FILE"
}


##############################
# Main program


if [ -z "$1" ]; then
	usage
	exit 1
fi

dependency_checks

if [ "$1" = "--install" ]; then
	install_maxapp
elif [ "$1" = "--remove" ]; then
	remove_maxapp
else
	usage
	exit 1
fi

echo
echo "Done."
exit 0
