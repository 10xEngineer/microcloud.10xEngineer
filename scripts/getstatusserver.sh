if (( $# != 1 ))
then
	echo "Usage: getstatusserver (local|ec2)"
	exit 1
fi

./scripts/init_env.sh # ensure JAVA_HOME is set for MacOSX (TODO fix to handle other env)

destination=$1

if [ "$1" = "local" ]
then
	cd a_vagrant_machine
	#TODO: how to get status from vagrant
	#vagrant halt
	#vagrant up
elif [ "$1" = "ec2" ]
then
	cd scripts/
	./ec2getstatus.sh -f tmp/ec2instance.out
else
	echo "Invalid destination $1 selected. Please choose local or ec2"
	exit 1
fi