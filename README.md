# maxapp_linux_installer
Linux installer for the Max! Java software

maxapp_linux_installer is a simple shell script to install/remove the original
Max! software for the Max! Cube system.

The script offers an automatic install/remove of the software for debian based
linux flavors (tested with Ubuntu 16.04, 18.04 and Debian Jessie).

The installer will check for missing dependencies and tries to install them. 
It needs sudo rights to do that.

## Usage:
To install the Max! Software you just need two steps:

	- Download the maxapp_linux_installer.sh script.
	- Run 'sh maxapp_linux_installer.sh --install' from a terminal.

Now you should find the MaxApp in your Menu under Utilites/Accesories.
You can also uninstall the software with the parameter --remove.

That's all :-)
