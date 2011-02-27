require 'rubygems'
require 'isaac'
require 'eventmachine'

INPUT = [ "hello there dummy", "are you bored?", "lets get some cheeseburgers"]

bot = Isaac::Bot.new do

        on :connect do
          $stdout.puts "Connected"
          INPUT.each {|m| msg "#test", m }
        end
        
        on :channel do
          $stdout.puts "#{nick}: #{message}"
        end
                
      end
      
bot.configure do |c|
  c.server = "127.0.0.1"
  c.port = 6667
end

EM.run {
  bot.start
}