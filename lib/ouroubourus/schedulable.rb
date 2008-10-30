module Ouroubourus
  module Schedulable
    
    attr_accessor :schedule
    
    def initialize(*a, &b)
      @schedule = Ouroubourus::Schedule.new
    end
    
    def run(time)
      schedule.run(time)
    end
    
  end
end