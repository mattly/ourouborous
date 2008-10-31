module Ouroubourus
  class Scheduler
    
    attr_accessor :subscribers, :timekeeper
    
    def initialize(options={})
      @subscribers = []
      @timekeeper = options[:timekeeper]
    end
    
    def start
      return false unless timekeeper.kind_of?(Ouroubourus::Timekeeper)
      timekeeper.start {|now| @subscribers.each{|s| Thread.start { s.run(now) } }}
    end

  end
end