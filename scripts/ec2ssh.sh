FILE_DATA=( $( /bin/cat tmp/publicdns.out ) )
publicdns=${FILE_DATA[0]}
echo "Connecting via SSH to " $publicdns

# need to wait for the status checks to pass before being able to ssh in
sleep 30
# attempts=0
# while [ $attempts -ne 3 ]
# do
	# attempts+=1	
	ssh -o "StrictHostKeyChecking no" -i ~/.ec2/velniukasEC2.pem ubuntu@$publicdns
	# sleep 5
# done
