module Ouroubourus
  module Timekeeper
    attr_reader :tempo, :resolution, :thread, :now
    
    def start(&block)
      @thread = Thread.start { @run.call(block) }
    end
    
    def stop
      @thread.stop
    end
    
    def resolution_in_seconds
      60.0 / @tempo / 480.0 * @resolution
    end
  end
end