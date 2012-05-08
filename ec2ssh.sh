FILE_DATA=( $( /bin/cat tmp/publicdns.out ) )
if [ -z $FILE_DATA ]
then
	Echo "publicdns.out is not found. No connection info available. Aborting."
	exit 1
fi
publicdns=${FILE_DATA[0]}
if [ -z "$publicdns" ]
then
	echo "Public DNS information not found in the publicdns.out file. Aborting."
	exit 1
fi

# need to wait for the status checks to pass before being able to ssh in
echo "Waiting 30s to connect via SSH to " $publicdns
sleep 30
# attempts=0
# while [ $attempts -ne 3 ]
# do
	# attempts+=1	
	ssh -o "StrictHostKeyChecking no" -i ~/.ec2/velniukasEC2.pem ubuntu@$publicdns
	# sleep 5
# done
