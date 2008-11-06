require 'lib/ourouborous'
require 'lib/devices/monome'
# require 'lib/sequencers/tape'

class GridKeyboard
  attr_accessor :rows, :cols, :grid, :sequencer, :step_x, :step_y, :basenote, :velocity, :notes
  attr_accessor :interface
  
  include Ourouborous::MIDI::Generator
  
  def initialize(cols, rows, options={})
    super
    @rows = rows
    @cols = cols
    
    @step_x = options[:step_x] || 2
    @step_y = options[:step_y] || 5
    @basenote = options[:basenote] || 36
    @velocity = options[:velocity] || 100
    @notes = Array.new(128, 0)
    
    @grid = Monome::Grid.new(cols, rows, L{|c,r,v| press(c,r,v) })
    # @sequencer = 
  end
  
  def press(col, row, val)
    pitch = (col * @step_x) + ((@rows.last - row - 1) * @step_y) + @basenote
    light(pitch, val)
    note(pitch, val)
  end
  
  def light(pitch, val)
    @notes[pitch] = [(@notes[pitch] + (val.zero? ? -1 : 1)), 0].max
    if (@notes[pitch].zero? && val.zero?) || (@notes[pitch] == 1 && val.nonzero?)
      pitch_to_coords(pitch).compact.each {|x,y| val ? @grid.on(x,y) : @grid.off(x,y) }
    end
  end
  
  def pitch_to_coords(pitch)
    rows.collect do |row|
      col = ((pitch - @basenote) - ((row - @rows.first) * @step_y)) / (@step_x * 1.0)
      if @cols.include?(col) && col == col.round
        [col.to_i, row]
      else 
        nil
      end
    end
  end
  
  def note(pitch, val)
    note_on(1, pitch, val.zero?? 0 : @velocity)
  end
  
end