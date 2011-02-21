### very basic example of pty - pseudo terminal - access to irb

require 'pty'

PTY.spawn('irb', '-f') do |outp, inp, pid|
  
  inp.write "true == false\n"
  buf = ""
  outp.readpartial(1024, buf) until buf =~ /^=>.*/
  print $&

end
