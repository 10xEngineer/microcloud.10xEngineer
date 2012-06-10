#/bin/sh

# basic dependencies
apt-get -y update                                                               
apt-get -y upgrade
apt-get -y install ruby1.9.3 build-essential vim 
apt-get clean

# install chef
/usr/bin/gem install chef --no-ri --no-rdoc 
