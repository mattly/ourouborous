$:.unshift File.dirname(__FILE__)
%w(lib/devices/monome lib/sequencers/step_sequencer).each {|r| require r }

class StepGrid
  
  attr_accessor :sequences, :sequencer
  
  def initialize(start_row, notes, options={})
    @start_row  = start_row
    @sequences  = []
    @steps      = options[:steps] || 16
    @sequencer  = StepSequencer.new({:interface => options[:interface], :steps => @steps})
    @monome     = options[:monome] # || raise "what the fuck"
    sequence_options = options[:sequences] || []
    notes.each_with_index do |note, row|
      seq = StepGrid::Sequence.new(note, @start_row + row, {:steps => @steps}.update(sequence_options[row]))
      @sequences << seq
      @sequencer.add_sequence seq.sequence
      @monome.add_subgrid seq.grid
      seq.redraw
    end
    @highlighter = StepGrid::Highlighter.new(@sequences)
    @sequencer.add_sequence @highlighter
  end
  
  class Sequence
    attr_accessor :grid, :sequence

    def initialize(pitch, row, options={})
      @steps = options.delete(:steps) || 16
      @sequence = StepSequencer::Sequence.new(pitch, options)
      @grid = Monome::Grid.new(0..(@steps-1), row, L{|c,r,v| Thread.start { pressing(c,v) } })
      @pressings = [0] * @steps
    end

    def pressing(col, val)
      if ! val.zero?
        val = @sequence.get(col).zero?? 1 : 0
        @sequence.set(col, val)
        @pressings[col] = 1
        @sequence.sequencer.schedule.in 120, L{|now| start_extended_press(col, now) }
      else
        @pressings[col] = 0
      end
      redraw
    end

    def start_extended_press(col, time)
      return if @pressings[col].zero?
      @pressings[col] = time
      @sequence.sequencer.schedule.in 60, L{|now| continue_extended_press(col, now) }
    end

    def continue_extended_press(col, time)
      return if @pressings[col].zero?
      percent = 1.0 - ((time - @pressings[col]) / 960.0)
      return if percent < 0.1
      @sequence.sequence[col] = percent
      @grid.blink(col, 0, 60, percent/3)
      @sequence.sequencer.schedule.in 60, L{|now| continue_extended_press(col, now) }
    end

    def redraw
      @sequence.sequence.each_with_index do |val, step|
        val == val.round ? (val.zero?? @grid.off(step, 0) : @grid.on(step, 0)) : @grid.blink(step, 0, 480, val)
      end
    end
  end
  
  class Highlighter
    attr_accessor :instruments, :sequencer
    def initialize(instruments)
      @instruments = instruments
    end

    def offs(step)
      @instruments.select {|i| i.sequence.get(step).zero? }
    end

    def run(step)
      offs(step).each {|i| i.grid.on(step,0) }
      L{|q| q.next 40, L{ offs(step).each {|i| i.grid.off(step,0) } } }
    end
  end
end