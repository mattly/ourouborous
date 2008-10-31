class Metronome
  include Ouroubourus::Schedulable
  include Ouroubourus::MIDI::Generator
  
  attr_accessor :interface, :signature, :channel #, :schedule
  
  def initialize(options={})
    super
    @signature = options[:signature] || [4,4]
    @interface = options[:interface]
    @channel   = options[:channel] || 1
    @basenote  = options[:basenote] || 72
    @run       = L do |now|
      play(now % bar_length == 0 ? one : beat)
      @schedule.next beat_length, @run
    end
    schedule.next beat_length, @run
  end
  
  def bar_length
    @signature.first * beat_length
  end
  
  def beat_length
    4.0 / @signature.last * 480
  end
  
  def one
    note(@basenote+12, 100, 180)
  end
  
  def beat
    note(@basenote, 60, 90)
  end
  
  def note(pitch, velocity, duration)
    Ouroubourus::MIDI::Note.new(pitch, velocity, duration, @channel, 0)
  end
end