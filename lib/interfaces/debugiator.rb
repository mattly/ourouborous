# use for debugging
class Debugiator
  
  def note(channel, pitch, velocity)
    puts "-- note! channel #{channel}, pitch #{pitch}, velocity #{velocity}"
  end
  
  def program_change(channel, program)
    puts "-- program-change! channel #{channel}, program #{program}"
  end
  
end