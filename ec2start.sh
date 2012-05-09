#!/bin/bash
echo "ec2start"
echo "============================================="

rm tmp/*.out > /dev/null 2>&1

ami='ami-a4ca8df6'
region='ap-southeast-1'
key='velniukasEC2'
type='t1.micro'

ec2-run-instances ${ami}							\
  --instance-type ${type}							\
  --key ${key}									\
  --region ${region}								\
  --user-data-file bootstrap.sh > tmp/ec2.out

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
  echo "FAILED ec2-run-instances to start "
  exit 1
fi

FILE_DATA=( $( /bin/cat tmp/ec2.out ) )
if [ -z $FILE_DATA ]
then
	Echo "ec2.out is not found. No instances available. Aborting."
	exit 1
fi
instance=${FILE_DATA[5]}
if [ -z "$instance" ]
then
	echo "Instance id not found in the ec2.out file. Aborting."
	exit 1
fi

echo "INSTANCE = " $instance
echo $instance > tmp/ec2instance.out

echo "ec2status"
echo "============================================="
./ec2status.sh $instance


FILE_DATA=( $( /bin/cat tmp/publicip.out ) )
if [ -z $FILE_DATA ]
then
	Echo "publicip.out is not found. No ip address is available. Aborting."
	exit 1
fi

publicip=${FILE_DATA[0]}

if [ -z "$publicip" ]
then
	echo "Public IP is not available from the publicip.out file. Aborting."
	exit 1
fi

echo "setup.sh"
echo "============================================="
echo "Waiting 30s for the server to finish initializing."
sleep 30

# now run the vagrant-ec2 code
./setup.sh $publicip a_vagrant_machine

# optional ssh into the machine
# ./ec2ssh.sh -a $publicip