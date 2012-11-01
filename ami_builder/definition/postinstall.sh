#/bin/sh

set -x -e
# basic dependencies
sudo dpkg --configure -a
sudo apt-get -f install
sudo DEBIAN_FRONTEND=noninteractive apt-get -y update 
sudo DEBIAN_FRONTEND=noninteractive apt-get -y upgrade

# install ruby and dependecies
sudo apt-get -y install ruby1.9.3 build-essential vim

sudo apt-get clean

# install chef
sudo /usr/bin/gem install chef --no-ri --no-rdoc

# preinstall
sudo apt-get -y install python-software-properties
sudo add-apt-repository -y ppa:zfs-native/stable

sudo DEBIAN_FRONTEND=noninteractive apt-get -y update 
sudo DEBIAN_FRONTEND=noninteractive apt-get -y upgrade

sudo apt-get -y install build-essential zlib1g-dev uuid-dev
sudo apt-get -y install spl-dkms spl zfs-dkms zfsutils