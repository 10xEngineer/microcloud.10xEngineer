#/bin/sh

# basic dependencies
sudo apt-get -y update                                                               
# grub-pc non interactive options
# http://askubuntu.com/questions/146921/how-do-i-apt-get-y-dist-upgrade-without-a-grub-config-prompt
sudo DEBIAN_FRONTEND=noninteractive apt-get -y upgrade
sudo apt-get -y install ruby1.9.3 build-essential vim 
sudo apt-get clean

# install chef
sudo /usr/bin/gem install chef --no-ri --no-rdoc 
