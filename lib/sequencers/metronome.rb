class Metronome
  include Ouroubourus::Schedulable
  
  attr_accessor :interface, :signature, :channel #, :schedule
  
  def initialize(options={})
    super
    @signature = options[:signature] || [4,4]
    @interface = options[:interface]
    @channel   = options[:channel] || 1
    @basenote  = options[:basenote] || 72
    @run       = L{|now| tick(now) }
    schedule.next 480, @run
  end
  
  def tick(now)
    note = (now % bar_length) == 0 ? one : beat
    @interface.driver.note_on(note[:pitch], @channel, note[:velocity])
    @schedule.in(note[:duration], L{ @interface.driver.note_off(note[:pitch], @channel, 0) })
    @schedule.next note_length, @run
  end
  
  def bar_length
    @signature.first * note_length
  end
  
  def note_length
    4.0 / @signature.last * 480
  end
  
  def one
    {:pitch => @basenote + 12, :velocity => 100, :duration => 180}
  end
  
  def beat
    {:pitch => @basenote, :velocity => 60, :duration => 90}
  end
end