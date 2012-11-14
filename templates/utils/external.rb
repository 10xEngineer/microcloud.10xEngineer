require 'open4'

# TODO make gem (used in microcloud/service, pool-node/lib)

module TenxLabs
  # from di-ruby-lvm / external
  module External

    class CommandFailure < RuntimeError; end

    def execute(cmd, raise_errors = true)
      output = []
      error = nil

      stat = Open4.popen4(cmd) do |pid, stdin, stdout, stderr|
        while line = stdout.gets
          output << line

          if block_given? 
            yield line
          end
        end

        error = stderr.read.strip
      end

      if stat.exited?
        if stat.exitstatus > 0
          error_message = error.empty? ? (output.delete_if {|i| i.strip.empty?}).first : error 

          if raise_errors
            raise CommandFailure, "Error (#{stat.exitstatus}): #{error_message}"
          else
            if block_given?
              yield error 
            else
              puts error
            end
          end

          return stat.exitstatus, error_message
        end
      elsif stat.signaled?
        raise CommandFailure, "Error - signal (#{stat.termsig}) and terminated."
      elsif stat.stopped?
        raise CommandFailure, "Error - signal (#{stat.termsig}) and is stopped."
      end

      return 0, output.join
    end

    module_function :execute
  end
end

