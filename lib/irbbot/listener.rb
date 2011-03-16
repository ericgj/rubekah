module IRBot
  Listener ||= Isaac::Bot.new do
    
    helpers do
      def input_queue=(q); @input_queue = q; end
      def input_queue; @input_queue ||= IRBot::PushQueue.new; end

      # needed for pseudo-IO functionality
      def print(*args); msg channel, args.join(" "); end
      def puts(*args); args.each {|arg| self.print arg}; end
      def flush; end
    end
    
    
    on :channel do
      unless (nick == config.nick) || (message == '!irb')
        input_queue.push message
      end
    end
    
    on :connect do
      input_queue.push "$SAFE = 2"    
    end
    
    on :quit do
      input_queue.push "exit"
    end
    
  end
    
end
