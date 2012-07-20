require 'yajl'

module TenxLabs
  module Mixin
    module ObjectTransform
      def to_json
        raise "Invalid class #{self.class.to_s}: missing #to_obj" unless self.class.method_defined? :to_obj

        hash = self.to_obj

        Yajl::Encoder.encode(hash)
      end
    end
  end
end