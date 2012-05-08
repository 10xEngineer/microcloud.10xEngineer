#!/bin/bash
rm *.out > /dev/null

ec2-run-instances ami-a4ca8df6			\
  --instance-type t1.micro			\
  --key velniukasEC2				\
  --region ap-southeast-1			\
  --user-data-file bootstrap.sh > ec2.out

RESULT=''
for job in `jobs -p`
do
  echo $job
  wait $job || let "RESULT='FAIL'"
done

if [ -z "$RESULT" ];
then
  echo "SUCCESS.. STARTED"
else
  echo "FAILED"
fi

FILE_DATA=( $( /bin/cat ec2.out ) )
instance=${FILE_DATA[5]}
echo "INSTANCE = " $instance
echo $instance > ec2instance.out

./ec2status.sh $instance

FILE_DATA=( $( /bin/cat publicdns.out ) )
publicdns=${FILE_DATA[0]}
echo "ssh to " $publicdns

# need to wait for the status checks to pass before being able to ssh in
sleep 30
# attempts=0
# while [ $attempts -ne 3 ]
# do
	# attempts+=1	
	ssh -o "StrictHostKeyChecking no" -i ~/.ec2/velniukasEC2.pem ubuntu@$publicdns
	# sleep 5
# done
