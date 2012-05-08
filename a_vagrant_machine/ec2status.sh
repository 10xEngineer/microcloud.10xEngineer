#!/bin/bash
rm ec2status.out > /dev/null
rm publicip.out > /dev/null
rm publicdns.out > /dev/null

status=''
count=0
echo "Starting up"
while [ "$status" != "running" ]
do
	ec2-describe-instances --region ap-southeast-1 $1 > ec2status.out

	FILE_DATA=( $( /bin/cat ec2status.out ) )
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
echo ${FILE_DATA[17]} > publicip.out
echo "PUBLIC DNS = " ${FILE_DATA[7]}
echo ${FILE_DATA[7]} > publicdns.out
