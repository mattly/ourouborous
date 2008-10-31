require 'midiator'

class Midiator
  
  attr_accessor :interface
  
  def initialize
    @interface = MIDIator::Interface.new
  end
  
  def note(channel, pitch, velocity)
    @interface.driver.note_on(pitch, channel, velocity)
  end
  
end