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
          on :channel, // do
            inp.write message
          end
        }
        
        @bot = Isaac::Bot.new(&BOT)
        #TODO config
        @bot.start

        # this isn't quite right
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

        #Thread.start {
        EM.run {
          conn = EM.watch BotWriter, @bot, outp
          conn.notify_readable = true
        }
        #}
        
      end
    end
    
  }
  
  on :channel, /^!irb$/ do
    if @irb_on = !@irb_on
      spawn
    else
      raw "exit"
    end
    
    raw "##### IRB " + (@irb_on ? 'on' : 'off')
    raw "$SAFE = 4" if irb_on
  end
   
}

superbot = Isaac::Bot.new(&SUPERBOT)
#TODO config
superbot.start

