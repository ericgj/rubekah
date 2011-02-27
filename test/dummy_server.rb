require 'rubygems'
require 'eventmachine'

module EchoIRC

  attr_accessor :nick
  
  def post_init
    @@connections ||= []
    @regstate = 0
    send_registration
  end
  
  def receive_data data
    (@buffer ||= BufferedTokenizer.new).extract(data).each do |line|
      receive_line(line)
    end  
  end
  
  def receive_line line
    $stdout.puts "<< #{line}"
    $stdout.flush
    if registered?
      case line 
      when /^QUIT/
        send_quit line
      else
        send_echo line
      end
    else
      case line 
      when /^PASS\s(\w+)/
      when /^NICK\s(\w+)/
        @nick = $1
        send_registration
      when /^USER\s(\w+)/
        send_registration
        send_registration
      end
    end
  end
    
  def registered?
    @@connections.include? self
  end
  
  def send_registration
    data = ":localhost 00#{@regstate += 1}\r\n"
    $stdout.puts ">> #{data}"
    $stdout.flush
    send_data data
    @@connections << self if @regstate == 4
  end
  
  def send_echo cmd
    @@connections.each do |conn|
      data = ":#{nick}! #{cmd}\r\n"
      $stdout.puts "  >> #{data}"
      $stdout.flush
      conn.send_data data
    end
  end
  
  def send_quit cmd
    send_echo "#{cmd.chomp} (quit)"
    close_connection_after_writing
  end
  
  def unbind
    @@connections.delete_if {|c| c == self}
  end
  
end

EM.run {
  $stdout.puts "Starting IRC dummy server on localhost:6667..."
  EM.start_server "127.0.0.1", 6667, EchoIRC
}