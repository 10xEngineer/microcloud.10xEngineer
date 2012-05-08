if (( $# != 1 ))
then
        echo "Usage: ec2stop <instance-id>" 
        exit 1
fi

ec2-stop-instances 				\
  --key ec2key					\
  --region ap-southeast-1			\
  $1
