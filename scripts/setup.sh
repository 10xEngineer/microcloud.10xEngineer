#!/bin/bash
#This script uploads everything required for `chef-solo` to run
set -e

if test -z "$2"
then
  echo "I need 
1) IP address of a machine to provision
2) Path to a Vagrant VM folder (a folder containing a Vagrantfile) that you want me to extract Chef recipes from"
  exit 1
fi

echo "in " ${PWD##*/}

#Run the Ruby script that reads Vagrantfile to make dna.json and cookbook tarball
echo "Making cookbooks tarball and dna.json"
echo "ruby `dirname $0`/ec2_package.rb $2"
ruby `dirname $0`/ec2_package.rb $2

#Try to match and extract a port provided to the script
ADDR=$1
IP=${ADDR%:*}
PORT=${ADDR#*:}
if [ "$IP" == "$PORT" ] ; then
    PORT=22
fi

USERNAME=ubuntu
COOKBOOK_TARBALL=$2/cookbooks.tgz
DNA=$2/dna.json

#make sure this matches the CHEF_FILE_CACHE_PATH in `bootstrap.sh`
CHEF_FILE_CACHE_PATH=/tmp/cheftime

#TODO - remove hard coding of private key
#Upload everything to the home directory (need to use sudo to copy over to $CHEF_FILE_CACHE_PATH and run chef)
echo "Uploading cookbooks tarball and dna.json"
scp -i ~/.ec2/velniukasEC2.pem -r -P $PORT -o "StrictHostKeyChecking no" \
  $COOKBOOK_TARBALL \
  $DNA \
  $USERNAME@$IP:.
#scp -v -i $EC2_SSH_PRIVATE_KEY -r -P $PORT \
#  $COOKBOOK_TARBALL \
#  $DNA \
#  $USERNAME@$IP:.

echo ""
echo "Check if bootstrap script is finished"
echo "------------------------------------------------------------------------------------------------------------"
echo ""

sleep 15
#attempts=5
#while [ $attempts -gt 0 ]; do
#	echo "$attempts"
#	#check to see if the bootstrap script has completed running
#	#eval "ssh -q -t -p \"$PORT\" -l \"$USERNAME\" -i \"$EC2_SSH_PRIVATE_KEY\" $USERNAME@$IP \"sudo -i which chef-solo > /dev/null \""
#	eval "ssh -q -t -o \"StrictHostKeyChecking no\" -p \"$PORT\" -l \"$USERNAME\" -i \"/Users/velniukas/.ec2/velniukasEC2.pem\" $USERNAME@$IP \"sudo -i which chef-solo  \""
#	if [ "$?" -ne "0" ] ; then
#	    # echo "chef-solo not found on remote machine; it is probably still bootstrapping, give it a minute."
#	    let attempts=attempts-1
#		echo "now $attempts left"
#		# exit
#	else
#		echo "bootstrapped."
#		break
#	fi
#done

echo ""
echo "Run chef-solo"  
echo "------------------------------------------------------------------------------------------------------------"

#Okay, run it.
#eval "ssh -t -p \"$PORT\" -l \"$USERNAME\" -i \"$EC2_SSH_PRIVATE_KEY\" $USERNAME@$IP \"sudo -i sh -c 'cd $CHEF_FILE_CACHE_PATH && \
eval "ssh -t -o \"StrictHostKeyChecking no\" -p \"$PORT\" -l \"$USERNAME\" -i \"/Users/velniukas/.ec2/velniukasEC2.pem\" $USERNAME@$IP \"sudo -i sh -c 'cd $CHEF_FILE_CACHE_PATH && \
cp -r /home/$USERNAME/cookbooks.tgz . && \
cp -r /home/$USERNAME/dna.json . && \
chef-solo -c solo.rb -j dna.json -r cookbooks.tgz'\""
