require 'rubygems'
require 'eventmachine'
require 'pty'

INPUT = [ "true", "true == false", "def fun; @it = 'noise!'; end", "Ashford == Simpson", "exit" ]

PTY.spawn('irb','-f') { |outp, inp, pid|
  
  module Printer
    
    def notify_readable
      buf = ""
      @io.readpartial(1024, buf) until buf =~ /^irb\(main\):\d*:\d*>/
      lines = buf.split($/)
      lines[1..-1].each do |line|
        $stdout.puts "#{line}" unless line =~ /^irb\(main\):\d*:\d*>/
        $stdout.flush
      end
    rescue EOFError
      detach
    end
    
    def unbind
      EM.next_tick do
        begin
        # socket is detached from the eventloop, but still open
          buf = ""; @io.readpartial(1024, buf)
          $stdout.print "BUFFER DUMP: #{buf}"
          $stdout.flush
        rescue EOFError
        end
        EM.stop
      end
    end
    
  end

  module Keyboard
    
    def notify_writable
      INPUT.empty? ? detach : @io.flush
    rescue
      $stdout.print "got writable error: #{$!}"; $stdout.flush    
    end
    
  end

  
  EM.run {
    INPUT << "exit"
    
    watch_out = EM.watch outp, Printer
    watch_out.notify_readable = true
    
    watch_in = EM.watch inp, Keyboard
    watch_in.notify_writable = true
    
    
    t = EM.add_periodic_timer(1) { 
      if it = INPUT.shift
        $stdout.puts "INPUT: #{it}"; $stdout.flush
        inp.puts it
      else
        EM.cancel_timer(t)
      end
    }

  }

  
}




__END__

### very basic example of pty - pseudo terminal - access to irb

require 'pty'

PTY.spawn('irb', '-f') do |outp, inp, pid|
  
  inp.write "true == false\n"
  buf = ""
  outp.readpartial(1024, buf) until buf =~ /^=>.*/
  print $&

end
