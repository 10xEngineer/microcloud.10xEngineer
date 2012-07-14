# aws/config.rb
require 'yaml'

module TenxLabs
  BASE_DIR = File.join(ENV['HOME'], ".10xlabs")
  AWS_CONFIG = ".10xlabs/aws.conf"

  def load_config
    YAML::load(File.open(File.join(ENV['HOME'], AWS_CONFIG)))
  end

  module_function :load_config
end

# create config dir if it doesn't exists
Dir.mkdir(TenxLabs::BASE_DIR) unless File.exists?(TenxLabs::BASE_DIR)