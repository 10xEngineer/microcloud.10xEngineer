# Argument = (-i <instance-id> | -f filename-containing-instance-id)

usage()
{
cat << EOF
usage: $0 options

This script will restart the specified ec2 server.

OPTIONS:
   -h      Show this message
   -i      Specify the instance id directly
   -f      Load instance id from a file
EOF
}

FILE=
instance=
while getopts “h:f:i” OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         i)
             instance=$OPTARG
			echo "instance=$instance"
             ;;
         f)
             FILE=$OPTARG
			echo "file=$FILE"
             ;;
         ?)
             usage
             exit
             ;;
     esac
done

if [[ -z $FILE ]] && [[ -z $instance ]]
then
	echo "empty params"
     usage
     exit 1
fi

if [ -z $instance ]
then
	echo "load file"
	FILE_DATA=( $( /bin/cat ${FILE} ) )
	if [ -z $FILE_DATA ]
	then
		Echo "$FILE is not found. No instances available. Aborting."
		exit 1
	fi
	instance=${FILE_DATA[0]}
	if [ -z "$instance" ]
	then
		echo "Instance id not found in the $FILE_DATA file. Aborting."
		exit 1
	fi
fi

echo "restarting down " $instance

#  --private-key '/Users/velniukas/.ec2/velniukasEC2.pem'		\
ec2-reboot-instances 					\
  --region ap-southeast-1			\
  $instance
