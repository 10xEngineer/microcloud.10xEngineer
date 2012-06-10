module TenxEngineer
  # 
  # list of based Ubuntu Images to use
  # http://cloud-images.ubuntu.com/releases/precise/release/
  #
  # Disclaimer: use 64-bit instance-store AMIs only
  #
  SOURCE_AMI = {
    "ap-northeast-1" => "ami-2cc7772d",
    "ap-southeast-1" => "ami-a0ca8df2",
    "eu-west-1" => "ami-1de8d369",
    "sa-east-1" => "ami-96d8068b",
    "us-east-1" => "ami-3c994355",
    "us-west-1" => "ami-e7712aa2",
    "us-west-2" => "ami-38800c08"
  }
end
