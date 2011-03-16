require 'rubygems'
require 'eventmachine'
require 'isaac'
require 'irb'

class RubyLex
  
  alias_method :initialize_original, :initialize
  def initialize(io=STDIN)
    initialize_original
    set_input(io)
  end
  
end

module IRB
  
  class Irb
    def initialize(workspace = nil, input_method = nil, output_method = nil)
      @context = Context.new(self, workspace, input_method, output_method)
      @context.main.extend ExtendCommandBundle
      @signal_status = :IN_IRB

      @scanner = RubyLex.new(output_method)
      @scanner.exception_on_syntax_error = false
    end
  end
  
  class EMQueueInputMethod < InputMethod

    def initialize(q=EM::Queue.new)
      super
      @line = []
      @line_no = -1
      q.pop {|line| @line << line }
    end

    def gets
      @line[@line_no += 1]
    end

    def eof?
      @line_no >= @line.size
    end

    def readable_atfer_eof?
      true
    end

    def line(line_no)
      @line[line_no]
    end

  end

  class QueueInputMethod < InputMethod

    def initialize(q=[])
      super
      @line = q
      @line_no = 0
    end

    def gets
      #puts "GOT HERE: #{@line.size}"
      @line_no += 1
      @line[@line_no - 1] 
    end

    def eof?
      @line_no > @line.size
    end

    def readable_atfer_eof?
      true
    end

    def line(line_no)
      @line[line_no]
    end

  end
  
  class IRCOutputMethod < OutputMethod
    def initialize(bot)
      @bot = bot
    end
    
    def print(*args)
      args.each {|arg| @bot.raw arg}
    end
  end
  
end

BOT = lambda {

  @irb_on = false
    
  helpers do
    def irb_start(bot)
#      irb = IRB::Irb.new(nil, 
#                          IRB::EMQueueInputMethod.new(@irb_q = EM::Queue.new), 
#                          self)
      IRB.init_config(nil)
      IRB.conf[:PROMPT_MODE] = :NULL
      IRB.conf[:RC] = false
      irb = IRB::Irb.new(nil,
                          IRB::QueueInputMethod.new(@irb_q = []), 
                          IRB::IRCOutputMethod.new(bot)
                        )
      IRB.conf[:MAIN_CONTEXT] = irb.context
      
      catch(:IRB_EXIT) do
        irb.eval_input
      end
      
      #irb
    end
    
  
  end

  on :channel, /^!irb$/ do
    if @irb_on = !@irb_on
      irb_start(self)       
     else
      raw "exit"
    end
    
    raw "===== IRB " + (@irb_on ? 'on' : 'off')
  end

  on :channel do
    @irb_q.push message if @irb_q && @irb_on
  end

   
}

if __FILE__ == $0
  
  require "#{File.dirname(__FILE__)}/helper"
  
  class TestBot < Test::Unit::TestCase

    def message(msg)
      Isaac::Message.new(":john!doe@example.com PRIVMSG #foo :#{msg}")
    end
    
    def setup
      @bot = Isaac::Bot.new(&BOT)
      @bot.config.environment = :test
      @socket, @server = start_mock_bot(@bot)
    end
   
    test "bot responds to !irb" do
      @bot.dispatch :channel, message("!irb")
      assert_equal "===== IRB on\n", @server.gets    
    end
    
    test "bot responds to !irb second time" do
      @bot.dispatch :channel, message("!irb")
      @bot.dispatch :channel, message("!irb")
      
      assert_equal "===== IRB on\n", @server.gets    
      assert_equal "exit\n", @server.gets
      assert_equal "===== IRB off\n", @server.gets    
    end
    
    test "bot responds to ruby expression" do
      @bot.dispatch :channel, message("!irb")
      @bot.dispatch :channel, message("true")
      @bot.dispatch :channel, message("!irb")

      assert_equal "===== IRB on\n", @server.gets    
      assert_equal "=> true\n", @server.gets
      assert_equal "exit\n", @server.gets    
      assert_equal "===== IRB off\n", @server.gets    
    end
    
  end
  
end
