class StepSequencer
  include Ouroubourus::Schedulable
  include Ouroubourus::MIDI::Generator
  
  attr_accessor :steps, :sequences, :interface
  
  def initialize(options={})
    super
    @steps      = options[:steps] || 16
    @rows       = options[:rows] || 1
    @interface  = options[:interface]
    @sequences  = []
    @run = L do |now|
      perform(now / step_length % @steps) # sixteenth notes
      schedule.next step_length, @run
    end
    schedule.first 1920, @run
  end
  
  def step_length
    1920 / @steps
  end
  
  def perform(step)
    results = @sequences.collect {|s| s.run(step) }.compact
    procs, notes = results.partition {|thing| thing.kind_of?(Array) }
    play notes
    procs.each {|p| schedule.next p.first, p.last }
  end
  
  class Sequence
    attr_accessor :pitch, :velocity, :duration, :sequence, :steps
    
    def initialize(pitch, options={})
      @pitch = pitch
      @velocity = options[:velocity] || 100
      @duration = options[:duration] || 80
      @steps    = options[:steps] || 16
      @sequence = (options[:sequence] || [0] * @steps).collect {|n| n.to_f }
    end
    
    def run(step)
      note(pitch, velocity_for(step).to_i, duration) if rand < @sequence[step]
    end
    
    def get(position)
      @sequence[position]
    end
    
    def set(position, value)
      @sequence[position] = value
    end
    
    def velocity_for(step, vel = @velocity)
      case vel
      when Numeric, String
        vel
      when Range
        random_in_range(vel)
      when Array
        velocity_for(step, vel[step])
      end
    end
    
    def interpret_velocity(vel)
      
    end
    
    def random_in_range(range)
      rand * (range.last - range.first) + range.first
    end
    
    def note(pitch, velocity, duration)
      Ouroubourus::MIDI::Note.new(pitch, velocity, duration, 1, 0)
    end
  end
  
end