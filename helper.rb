require 'rubygems'
require 'isaac'
require 'test/unit'
require 'contest'
require 'rr'
require 'timeout'
begin
  require 'ruby-debug'
rescue LoadError; end


#
#  proposed usage of dummy irc server in test cases
#
#  def react(bot, &blk)
#    svr = DummyServer.new
#    irc = svr.fork
#    EM.run {
#      bot.start
#      dummy = DummyBot.start
#      yield(EM, dummy)
#    }
#    irc.exit
#  end
#
#  def input(lines, opts = {})
#    throttle = opts[:throttle] || 1
#    react(@bot) do |reactor, user|
#      lines.each_with_index do |line, i|
#        reactor.add_timer(i * throttle) { user.send line }
#      end
#    end
#  end
#
#  test "something" do
#    @bot = MyBot.dummy!
#    input(["!irb", "true", "!irb"])
#    @bot.transcript(@bot.nick).should_equal(
#      ["##### IRB on", "=> true", "##### IRB off"])
#  end
#
#

######## or is that too much work for too little gain?
#
# I think the below could work if we stub out Bot.start or IRC.connect
#

class MockSocket
  def self.pipe
    socket1, socket2 = new, new
    socket1.in, socket2.out = IO.pipe
    socket2.in, socket1.out = IO.pipe
    [socket1, socket2]
  end

  attr_accessor :in, :out
  def gets()
    Timeout.timeout(5) {@in.gets}
  end
  def puts(m) @out.puts(m) end
  def print(m) @out.print(m) end
  def eof?() @in.eof? end
  def empty?
    begin
      @in.read_nonblock(1)
      false
    rescue Errno::EAGAIN
      true
    end
  end
  
  def message(m) puts(m) end
end
  
class Test::Unit::TestCase
  include RR::Adapters::TestUnit

  def stub_irc(io)
    stub(::Isaac::IRC).connect(anything, anything) { io }
  end
  
  def start_mock_bot(bot=nil, &blk)
    bot ||= Isaac::Bot.new(&blk) if block_given?
    socket, server = MockSocket.pipe
    stub_irc(socket)
    Thread.start { bot.start }
    [socket, server]
  end
  
end