class StepSequencer
  include Ouroubourus::Schedulable
  include Ouroubourus::MIDI::Generator
  
  attr_accessor :size, :sequences, :interface
  
  def initialize(options={})
    super
    @rows   = options[:rows] || 1
    @interface = options[:interface]
    @sequences = []
    @run = L do |now|
      step((now % 1920) / 120) # sixteenth notes
      @schedule.next 480/4, @run
    end
    schedule.first 480/4, @run
  end
  
  def step(sixteenth)
    play @sequences.collect {|s| s.step(sixteenth) }.compact
  end
  
  class Sequence
    attr_accessor :pitch, :velocity, :duration, :sequence
    
    def initialize(pitch, options={})
      @pitch = pitch
      @velocity = options[:velocity] || 100
      @duration = options[:duration] || 80
      @sequence = options[:sequence].collect{|i| i.to_i } || [1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0]
    end
    
    def step(step)
      note(pitch, velocity, duration) if rand < @sequence[step]
    end
    
    def note(pitch, velocity, duration)
      Ouroubourus::MIDI::Note.new(pitch, velocity, duration, 1, 0)
    end
  end
  
end