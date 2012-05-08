#!/bin/bash
rm tmp/*.out > /dev/null 2>&1

ami='ami-a4ca8df6'
region='ap-southeast-1'
key='velniukasEC2'
type='t1.micro'

ec2-run-instances $ami			\
  --instance-type $type			\
  --key $key					\
  --region $region				\
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
instance=${FILE_DATA[5]}
echo "INSTANCE = " $instance
echo $instance > tmp/ec2instance.out

./ec2status.sh $instance

FILE_DATA=( $( /bin/cat tmp/publicip.out ) )
publicip=${FILE_DATA[0]}

# now run the vagrant-ec2 code
./setup.sh $publicip ../a_vagrant_machine/

# optional ssh into the machine
# ./ec2ssh.sh