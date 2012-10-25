require 'sshkey'

class KeyService < Provider
  def create(request)
    length = (request["options"]["length"] || "2048").to_i
    passphrase = request["options"]["passphrase"] || nil

    key = SSHKey.generate :type => "RSA", :bits => length, :passphrase => passphrase
    
    return response :ok, {
        :identity => key.rsa_private_key, 
        :public => key.ssh_public_key,
        :fingerprint => key.fingerprint
    }
  end

  def validate(request)
  		key = request["options"]["key"]

  		raise "Missing key to validate" unless key and !key.empty?

  		if SSHKey.valid_ssh_public_key? key
  			fingerprint = SSHKey.fingerprint key

  			return response :ok, {
  				:fingerprint => fingerprint
  			}
  		else
  			response :fail, {
  				:reason => "Invalid SSH key"
  			}
  		end
  end
end
