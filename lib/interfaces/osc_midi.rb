class OscMidi
  
  attr_accessor :speaker, :prefix, :send_port, :send_address
  
  def initialize(options={})
    @send_port    = options[:send_port] || 9000
    @send_address = options[:send_address] || "0.0.0.0"
    @prefix       = options[:prefix] || "/midi"
    @speaker      = options[:speaker]
  end
  
  def note(channel, pitch, velocity)
    speak 'note', channel, pitch, velocity
  end
  
  def program_change(channel, program)
    speak 'program_change', channel, program
  end
  
  protected
  def speak(*message)
    command = message.shift
    command = "#{@prefix}/#{command}"
    @speaker.speak([command, message], @send_address, @send_port)
  end
  
end