require 'midiator'

class Midiator
  
  attr_accessor :interface
  
  def initialize
    @interface = MIDIator::Interface.new
    @interface.autodetect_driver
  end
  
  def note(channel, pitch, velocity)
    @interface.driver.note_on(pitch, channel, velocity)
  end
  
  def program_change(channel, program)
    @interface.program_change channel, program
  end
  
end