require 'digest/sha2'

module TenxEngineer
  def self.server_token(id, salt = 'Falcon 9')
    source = "#{salt}-#{Time.now.utc}-#{id}"

    hash = Digest::SHA2.new
    hash.update(source)

    hash.hexdigest!
  end
end
