require 'fog'
require 'commander'
require 'commander/delegates'

include Commander::UI                                                           
include Commander::UI::AskForClass                                              
include Commander::Delegates

$terminal.wrap_at = HighLine::SystemExtensions.terminal_size.first - 5 rescue 80 if $stdin.tty?

program :name, "10xaws-setup"
program :version, "0.0.1"
program :description, "10xLabs AWS setup"
program :help_formatter, :compact

require 'aws/config'

$config = TenxLabs::load_config

require 'aws/setup_commands.rb'

Commander::Runner.instance.run!
