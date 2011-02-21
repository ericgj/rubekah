require 'rubygems'
require 'eventmachine'
require 'isaac'
require 'pty'

SUPERBOT = lambda {

  @irb_on = false
  
  helpers do {
  
    def spawn
      PTY.spawn('irb', '-f') do |outp, inp, pid|

        BOT = lambda {
          ## TODO == inp.write message
        }
        
        @bot = Isaac::Bot.new(&BOT)
        @bot.start

        module BotWriter
        
          def initialize(bot, io)
            @bot = bot; @io = io
          end
          
          def notify_readable
            @bot.raw @io.readline
            rescue EOFError
              detatch
            end
          end
          
        end

        EM.run {
          conn = EM.watch BotWriter, @bot, outp
          conn.notify_readable = true
        }
        
      end
    end
    
  }
  
  on :channel, /^!irb$/ do
    if @irb_on = !@irb_on
      spawn
      raw "$SAFE = 4"
    else
      raw "exit"
    end
    
    raw "===== IRB " + (@irb_on ? 'on' : 'off')
  end
   
}

Isaac::Bot.new(&SUPERBOT).start

