module Ouroubourus
  class LocalTimer
    include Ouroubourus::Timekeeper
    
    def initialize(tempo=120.0, options={})
      @tempo = tempo
      
      # '1' is 480 pulses per quarter note. 20 is 24ppq, the same as midi clock
      @resolution = (options[:resolution] || 20).round
      
      @now = 0
      
      @run = L do |b|
        loop do
          b.call(@now)
          sleep resolution_in_seconds
          @now += @resolution
        end
      end
    end
    
  end
end