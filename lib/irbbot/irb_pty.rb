require 'rubygems'
require 'eventmachine'
require 'pty'

module IRBot
  class PTY
    
    module Printer
      
      def initialize(extout = $stdout)
        @extout = extout
      end
      
      def notify_readable
        buf = ""
        @io.readpartial(1024, buf) until buf =~ /^irb\(main\):\d*:\d*>/
        lines = buf.split($/)
        lines[1..-1].each do |line|
          @extout.puts "#{line}" unless line =~ /^irb\(main\):\d*:\d*>/
          @extout.flush
        end
      rescue EOFError
        detach
      end
      
      def unbind
        EM.next_tick do
          begin
          # socket is detached from the eventloop, but still open
            buf = ""; @io.readpartial(1024, buf)
            @extout.puts "BUFFER DUMP: #{buf}"
            @extout.flush
          rescue EOFError
          end
          EM.stop
        end
      end
      
    end
  
    module Keyboard
      
      def notify_writable
        @io.flush
      end
      
    end

    attr_accessor :extout
    
    def self.spawn extout, &blk
      pty = new
      pty.extout = extout
      pty.on_input(&blk)
      pty.spawn
    end
    
    def on_input &blk
      @on_input_block = blk
    end
    
    def spawn
      ::PTY.spawn('irb','-f') do |outp, inp, pid|
        
        Signal.trap('INT') { EM.next_tick { EM.stop } }
        Signal.trap('TERM') { EM.next_tick { EM.stop } }
        
        EM.run {
        
          watch_out = EM.watch outp, Printer, extout
          watch_out.notify_readable = true
          
          watch_in = EM.watch inp, Keyboard
          watch_in.notify_writable = true
          
          @on_input_block.call(inp) if @on_input_block
        }  
      end
    end
    
  end
  
end

__END__

# Example async usage with EM::Queue

q = EM::Queue.new
IRBot::PTY.spawn(out) do |inp| 
  q.pop {|item| inp.puts item}
end
    

# Example polling usage

q = []
IRBot::PTY.spawn(out) do |inp| 
  EM.add_periodic_timer(1) { inp.puts q.shift unless q.empty? }
end
