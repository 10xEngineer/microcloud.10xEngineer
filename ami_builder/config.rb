module TenxEngineer
  # 
  # list of based Ubuntu Images to use
  # http://cloud-images.ubuntu.com/releases/precise/release/
  #
  # Disclaimer: use 64-bit EBS instances
  #
  SOURCE_AMI = {
    :ubuntu => {
      "ap-northeast-1" => "ami-60c77761",
      "ap-southeast-1" => "ami-a4ca8df6",
      "eu-west-1" => "ami-e1e8d395",
      "sa-east-1" => "ami-8cd80691",
      "us-east-1" => "ami-a29943cb",
      "us-west-1" => "ami-87712ac2",
      "us-west-2" => "ami-20800c10"
    },
    :windows => {
      "ap-southeast-1" => "ami-70d49222",
      "ap-northeast-1" => "ami-fc70c3fd",
      "eu-west-1" => "ami-e1d3d695",
      "sa-east-1" => "ami-180ad405",
      "us-east-1" => "ami-2ccd6e45",
      "us-west-1" => "ami-e7ce94a2",
      "us-west-2" => "ami-40179b70"
    }
  }
end
