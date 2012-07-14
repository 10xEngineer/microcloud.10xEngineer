# aws/config.rb

module TenxLabs
  BASE_DIR = File.join(ENV['HOME'], ".10xlabs")
  AWS_CONFIG = ".10xlabs/aws.conf"
end

# create config dir if it doesn't exists
Dir.mkdir(TenxLabs::BASE_DIR) unless File.exists?(TenxLabs::BASE_DIR)