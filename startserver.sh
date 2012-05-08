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
else if [ "$1" = "ec2" ]
	scripts/ec2start.sh
	scripts/ec2ssh.sh
else
	echo "Invalid destination $1 selected. Please choose local or ec2"
	exit 1
fi