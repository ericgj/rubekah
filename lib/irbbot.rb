require 'rubygems'
require 'eventmachine'
require 'isaac/bot'

require_relative 'irbbot/push_queue'
require_relative 'irbbot/irb_pty'
require_relative 'irbbot/listener'
require_relative 'irbbot/supervisor'

module IRBot

  VERSION = '0.0.2'
  
  HOME = File.join(File.expand_path(File.dirname(__FILE__)),'..')
  
end



require_relative 'irbbot/runner'
