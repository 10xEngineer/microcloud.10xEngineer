# Argument = (-a <public-dns> | -f filename-containing-instance-id)

usage()
{
cat << EOF
usage: $0 options

This script will stop the specified ec2 server.

OPTIONS:
   -h      Show this message
   -a      Specify the publicdns directly
   -f      Load publicdns from a file
EOF
}

FILE=
publicdns=
while getopts “h:f:a” OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         i)
             publicdns=$OPTARG
			echo "public dns=$publicdns"
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

if [[ -z $FILE ]] && [[ -z $publicdns ]]
then
	echo "empty params"
     usage
     exit 1
fi

if [ -z $publicdns ]
then
	echo "load file"
	FILE_DATA=( $( /bin/cat ${FILE} ) )
	if [ -z $FILE_DATA ]
	then
		Echo "$FILE is not found or is empty. No connection info available. Aborting."
		exit 1
	fi
	publicdns=${FILE_DATA[0]}
	if [ -z "$publicdns" ]
	then
		echo "Public DNS info not found in the $FILE_DATA file. Aborting."
		exit 1
	fi
fi

echo "connecting to " $publicdns

# need to wait for the status checks to pass before being able to ssh in
# echo "Waiting 30s to connect via SSH to " $publicdns
#sleep 30
# attempts=0
# while [ $attempts -ne 3 ]
# do
	# attempts+=1	
	ssh -o "StrictHostKeyChecking no" -i ~/.ec2/velniukasEC2.pem ubuntu@$publicdns
	# sleep 5
# done
