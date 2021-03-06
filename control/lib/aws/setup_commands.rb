# aws/setup_commands.rb
require 'aws/config'

command :security do |c|
  c.description = "Configure security groups"

  c.option "--region REGION", String, "Use only selected region (overrides configuration)"
  c.action do |args, options|
    # regions to process
    regions = []
    if options.region
      regions << options.region
    else
      regions = $config[:regions]
    end

    # create security group
    regions.each do |region|
      # FIXME continue
    end

    # TODO get config
    # TOGO get regions or use the one specified in commands
  end
end

command :config do |c|
  c.description = "Configure credentials used for AWS setup (not operations)"
  c.option "--access_key KEY", String, "AWS Access Key ID"
  c.option "--secret KEY", String, "AWS Secret Access Key"

  c.action do |args, options|
    config_file = File.join(ENV['HOME'], TenxLabs::AWS_CONFIG)

    if File.exists?(config_file)
      abort "10xLabs AWS config already exists: #{config_file}"
    else
      say "Running 10xLabs AWS config..."
    end

    unless options.access_key && options.secret
      say "\n"
      say "Your AWS credentials are available in My Account/Security Credentials for basic setup, "
      say "or refer to Amazon IAM setup (advanced, need to have administrator permissions)."
      say "\n"
    end

    options.access_key = ask("AWS Access Key ID: ") unless options.access_key
    options.secret = ask("AWS Secret: ") unless options.secret

    begin
      say "Verifying provided credentials..."

      connection = Fog::Compute.new({
        :provider => 'AWS',
        :aws_secret_access_key => options.secret,
        :aws_access_key_id => options.access_key,
        :region => "us-east-1"
        })

      regions = connection.describe_regions

      # write credentials
      config = {
        :master => {
          'aws_access_key_id' => options.access_key,
          'aws_secret_access_key' => options.secret
        }
      }

      config[:regions] = []
      regions.body["regionInfo"].each do |region|
        config[:regions] << region["regionName"]
      end

      File.open(config_file, 'w') do |f|
        f.puts YAML.dump(config)
      end

      say "AWS credentials stored in #{config_file} together with all available regions. If you want to limit regions, please, adjust list accordingly."
    rescue Fog::Compute::AWS::Error => e
      say e.message

      abort
    end
  end
end
