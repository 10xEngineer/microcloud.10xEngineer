if (( $# != 1 ))
then
	echo "Usage: startserver (local|ec2)"
	exit 1
fi

destination=$1

if [ "$1" = "local" ]
then
	cd a_vagrant_machine
	vagrant up
	vagrant ssh
	# optional shut down 
	vagrant halt
elif [ "$1" = "ec2" ]
then
	# cd scripts/
	./ec2start.sh
	echo "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
	#./ec2ssh.sh -f tmp/publicdns.out
	# optional shutdown
	./ec2stop.sh -f tmp/ec2instance.out
else
	echo "Invalid destination $1 selected. Please choose local or ec2"
	exit 1
fi