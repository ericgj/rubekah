
bot = IRBot::Listener
superbot = IRBot::Supervisor

bot.configure_from("#{IRBot::HOME}/config/listener.rb")
superbot.configure_from("#{IRBot::HOME}/config/supervisor.rb")

superbot.child_bot = bot
superbot.input_queue = bot.input_queue


Signal.trap('INT') { EM.next_tick { EM.stop } }
Signal.trap('TERM') { EM.next_tick { EM.stop } }

EM.run {
  superbot.start
  
###### uncomment to test
#  EM.add_timer(2) { superbot.msg "#test", "!irb" }
#  EM.add_timer(3) { superbot.msg "#test", "Math::PI" }
#  EM.add_timer(4) { superbot.msg "#test", "rand(100)" }
#  EM.add_timer(5) { superbot.msg "#test", "require 'csv'" }
#  EM.add_timer(6) { superbot.msg "#test", "def greet" }
#  EM.add_timer(7) { superbot.msg "#test", "  'hello!'" }
#  EM.add_timer(8) { superbot.msg "#test", "end" }
#  EM.add_timer(9) { superbot.msg "#test", "`ls -a`" }
#  EM.add_timer(10) { superbot.msg "#test", "eval('$SAFE=1')" }
#  EM.add_timer(11) { superbot.msg "#test", "!irb" }

}