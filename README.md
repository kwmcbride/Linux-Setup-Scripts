# Linux Setup Scripts (mostly)

These are some scripts I use to set up a new installation of Ubuntu based distributions. It is a hassle to make all of the necessary installations each time you install a new distro, so this helps ease the process.

## setup_OS.sh

This is the first script to run right after installing. For me the most important steps are getting python installed along with pyenv and poetry. Other critical programs are included here as well. This list may change frequently as I find more things that should be added to it.

## install_ipopt.sh

Installing IPOPT is really a pain. Seriously. This script handles everything for you and at least works on Linux Mint 20.1. For a proper IPOPT experience, you should get the HSL libraries as well.

## install_k_aug.sh

This is probably less fun to install than IPOPT. Since they use several of the same libraries, you should already have IPOPT installed. This takes care of k_aug installation automatically, but I can't guarantee that it will work on your system (Linux).

To use this, you need to have the dependencies already installed. The latest version of this script will find the location of the key shared objects automatically by finding the latest version of the file in the expected folders. You should update the directories at the top of the folder with your specific installation locations (ASL, HSL).

It should work. It does for me.

## install_k_aug_mac_os.sh

The same as above but modified to work on Mac OS (only tested on Big Sur).
