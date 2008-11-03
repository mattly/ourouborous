module Ourouborous
  class Scheduler
    
    attr_accessor :subscribers, :timekeeper
    
    def initialize(options={})
      @subscribers = []
      @timekeeper = options[:timekeeper]
    end
    
    def start
      return false unless timekeeper.kind_of?(Ourouborous::Timekeeper)
      timekeeper.start {|now| @subscribers.each{|s| s.run(now) }}
    end

  end
end