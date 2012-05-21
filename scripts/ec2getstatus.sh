# Argument = (-i <instance-id> | -f filename-containing-instance-id)
rm tmp/ec2getstatus.out > /dev/null 2>&1


usage()
{
cat << EOF
usage: $0 options

This script will get the status of the specified ec2 server.

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

echo "getting status for " $instance

ec2-describe-instances --region ap-southeast-1 $1 > tmp/ec2getstatus.out

FILE_DATA=( $( /bin/cat tmp/ec2status.out ) )
status=${FILE_DATA[9]}
echo -n "."
sleep 2
echo "INSTANCE = " $1
echo "STATUS = " ${FILE_DATA[9]}
echo "PUBLIC IP = " ${FILE_DATA[17]}
echo "PUBLIC DNS = " ${FILE_DATA[7]}

