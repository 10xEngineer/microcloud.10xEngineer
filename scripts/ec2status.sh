#!/bin/bash
rm tmp/ec2status.out > /dev/null 2>&1
rm tmp/publicip.out > /dev/null 2>&1
rm tmp/publicdns.out > /dev/null 2>&1

if (( $# != 1 ))
then
	echo "Usage: ec2status <instance-id>"
	exit 1
fi 

status=''
count=0
echo "Getting status"
while [ "$status" != "running" ]
do
	ec2-describe-instances --region ap-southeast-1 $1 > tmp/ec2status.out

	FILE_DATA=( $( /bin/cat tmp/ec2status.out ) )
	# for I in $(/usr/bin/seq 0 $((${#FILE_DATA[@]} - 1)))
	# do
	# 	echo $I ${FILE_DATA[$I]}
	# done
	status=${FILE_DATA[9]}
	echo -n "."
	sleep 2
done

echo "INSTANCE = " $1
echo "STATUS = " ${FILE_DATA[9]}
echo "PUBLIC IP = " ${FILE_DATA[17]}
echo ${FILE_DATA[17]} > tmp/publicip.out
echo "PUBLIC DNS = " ${FILE_DATA[7]}
echo ${FILE_DATA[7]} > tmp/publicdns.out
