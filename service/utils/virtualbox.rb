module TenxEngineer
  module VirtualBox
    def self.detect?
      return true if File.exists?("/dev/vboxguest") || File.exists?("/proc/irq/9/vboxguest")

      false
    end
  end
end
