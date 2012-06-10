module TenxEngineer
  # 
  # list of based Ubuntu Images to use
  # http://cloud-images.ubuntu.com/releases/precise/release/
  #
  # Disclaimer: use 64-bit EBS instances
  #
  SOURCE_AMI = {
    "ap-northeast-1" => "ami-60c77761",
    "ap-southeast-1" => "ami-a4ca8df6",
    "eu-west-1" => "ami-e1e8d395",
    "sa-east-1" => "ami-8cd80691",
    "us-east-1" => "ami-a29943cb",
    "us-west-1" => "ami-87712ac2",
    "us-west-2" => "ami-20800c10"
  }
end
