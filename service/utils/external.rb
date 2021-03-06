require 'open4'

module TenxLabs
  # from di-ruby-lvm / external
  module External

    class CommandFailure < RuntimeError; end

    def execute(cmd)
      output = []
      error = nil

      stat = Open4.popen4(cmd) do |pid, stdin, stdout, stderr|
        while line = stdout.gets
          output << line
        end

        error = stderr.read.strip
      end

      if stat.exited?
        if stat.exitstatus > 0
          error_message = error.empty? ? (output.delete_if {|i| i.strip.empty?}).first : error 

          raise CommandFailure, error_message
        end
      elsif stat.signaled?
        raise CommandFailure, "Error - signal (#{stat.termsig}) and terminated."
      elsif stat.stopped?
        raise CommandFailure, "Error - signal (#{stat.termsig}) and is stopped."
      end

      if block_given?
        return output.each { |l| yield l}
      else
        return output.join
      end
    end

    module_function :execute
  end
end

