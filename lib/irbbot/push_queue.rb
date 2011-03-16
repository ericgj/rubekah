module IRBot

  # This is similar to behavior of EM::Queue, except
  # there is just _one_ call to pop that defines the callback for _every_ pushed item
  # On every push, this callback fires
  #
  # This is used here to asynchronously move input messages from the queue to the irb input stream
  #
  class PushQueue < EM::Queue
  
    def pop(*a, &b)
      cb = EM::Callback(*a, &b)
      EM.schedule do
        @popq << cb
        if @items.empty?
        else
          @popq.last.call @items.shift
        end
      end
      nil # Always returns nil
    end
  
    def push(*items)
      EM.schedule do
         @items.push(*items)
         @popq.last.call @items.shift until @items.empty? || @popq.empty?
      end
    end
    
  end
  
end