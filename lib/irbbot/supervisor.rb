module IRBot
  
  Supervisor ||= Isaac::Bot.new do

    helpers do
      def child_bot=(b); @child_bot = b; end
      def child_bot; @child_bot; end

      def input_queue=(q); @input_queue = q; end
      def input_queue; @input_queue ||= IRBot::PushQueue.new; end
          
      def irb!; @irb_on = !(@irb_on); end
      def irb?; @irb_on == true; end
          
      def spawn
        # TODO raise error unless child_bot
        IRBot::PTY.spawn(child_bot) do |inp| 
          input_queue.pop {|item| $stdout.puts "input queue pop: #{item}"; $stdout.flush; inp.puts item}
        end      
      end
      
    end
    
    on :channel, /^!irb$/ do
      # TODO raise error unless child_bot
      if irb!
        msg channel, "##### IRB on"
        child_bot.start
        EM.next_tick { spawn }
      else
        child_bot.quit
        EM.add_timer(1) { msg channel, "##### IRB off" }
      end
      
    end
    
  end
  
end
