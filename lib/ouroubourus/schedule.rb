module Ouroubourus
  class Schedule
    
    attr_accessor :time, :queue
    
    def initialize
      @time = 0
      @queue = []
    end
    
    def run(now)
      @time = now
      ready, @queue = @queue.partition {|pos, proc| pos <= now }
      ready.each {|time, proc| Thread.start { proc.call(time) } }
    end
    
    def at(position, block)
      @queue.push [position.to_i, block]
    end
    
    def in(delta, block)
      at (@time + delta.to_i.abs), block
    end
    
    def next(multiple, block)
      at (@time + multiple - (@time % multiple)), block
    end
    
  end
end