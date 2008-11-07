class GridKeyboard
  attr_accessor :rows, :cols, :grid, :sequencer, :step_x, :step_y, :basenote, :velocity, :notes
  attr_accessor :interface
  
  include Ourouborous::MIDI::Generator
  
  def initialize(cols, rows, options={})
    setup_notes
    @rows = rows
    @cols = cols
    @row_count = rows.last - rows.first
    
    @step_x = options[:step_x] || 2
    @step_y = options[:step_y] || 5
    @basenote = options[:basenote] || 36
    @velocity = options[:velocity] || 100
    @notes = Array.new(128, 0)
    
    @channel = options[:channel] || 1
    @grid = Monome::Grid.new(cols, rows, L{|c,r,v| press(c,r,v) })
    @interface = options[:interface]
    # @sequencer = 
  end
  
  def press(col, row, val)
    pitch = (col * @step_x) + ((@row_count - row) * @step_y) + @basenote
    puts "pressed: #{row}: #{pitch}"
    return unless VALID_PITCHES.include?(pitch)
    light(pitch, val)
    note(pitch, val)
  end
  
  def light(pitch, val)
    @notes[pitch] = [(@notes[pitch] + (val.zero? ? -1 : 1)), 0].max
    # if (@notes[pitch].zero? && val.zero?) || (@notes[pitch] == 1 && val.nonzero?)
      pitch_to_coords(pitch).compact.each {|x,y| val.nonzero? ? @grid.on(x,y) : @grid.off(x,y) }
    # end
  end
  
  def pitch_to_coords(pitch)
    (0..@row_count).collect do |row|
      col = ((pitch - @basenote) - (row * @step_y)) / (@step_x * 1.0)
      puts "light: #{col}, #{row}"
      
      if @cols.include?(col) && col == col.round && row < @row_count + 1
        [col.to_i, @row_count - row]
      else 
        nil
      end
    end
  end
  
  def note(pitch, val)
    note_on(@channel, pitch, val.zero?? 0 : @velocity)
  end
  
end