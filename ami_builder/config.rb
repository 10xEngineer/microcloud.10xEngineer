module TenxEngineer
  # 
  # list of based Ubuntu Images to use
  # http://cloud-images.ubuntu.com/releases/precise/release/
  #
  # Disclaimer: use 64-bit EBS instances
  #
  SOURCE_AMI = {
    :ubuntu => {
      "ap-northeast-1" => "ami-c641f2c7",
      "ap-southeast-1" => "ami-acf6b0fe",
      "eu-west-1" => "ami-e9eded9d",
      "sa-east-1" => "ami-5c03dd41",
      "us-east-1" => "ami-82fa58e",
      "us-west-1" => "ami-5965401c",
      "us-west-2" => "ami-4438b474"
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
