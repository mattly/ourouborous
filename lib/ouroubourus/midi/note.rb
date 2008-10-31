module Ouroubourus
  module MIDI
    class Note
      
      attr_reader :pitch, :velocity, :duration, :start, :channel
      
      def initialize(p, vel, dur, chan=1, s=0)
        self.pitch = p
        self.velocity = vel
        self.channel = chan
        self.duration = dur
        self.start = s
      end
      
      def pitch=(val)
        @pitch = seven_bit(val)
      end
      
      def velocity=(val)
        @velocity = seven_bit(val)
      end
      
      def channel=(val)
        val = 1 if val < 1
        val = 16 if val > 16
        @channel = val
      end
      
      def duration=(val)
        @duration = [1,val].max
      end
      
      def start=(val)
        @start = [0,val].max
      end
      
    protected
      def seven_bit(val)
        val = 0 if val < 0
        val = 127 if val > 127
        val
      end
    end
  end
end