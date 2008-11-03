#! /usr/bin/env ruby
# requires a monome, monomeSerial running, sending on /monome to port 8000 and listening on 8080
# also requires datagrammer, gem install mattly-datagrammer from github

tempo = 120
steps = 16   # 40h or 64 users! change to 8

require 'rubygems'
require 'midiator'
require 'datagrammer'
require 'lib/ourouborous'
require 'lib/interfaces/midiator'
require 'lib/devices/monome'
require 'lib/sequencers/step_sequencer'

require 'ruby-debug'
Debugger.start

@s = Ourouborous::Scheduler.new :timekeeper => Ourouborous::LocalTimer.new(tempo)
@midi = Midiator.new
@midi.interface.autodetect_driver
@midi.interface.program_change 0, 115 # wood block
@midi.interface.driver.instance_variable_set(:@destination, MIDIator::Driver::CoreMIDI::C.mIDIGetDestination(1)) # ugly hack for now
@beats = StepSequencer.new :interface => @midi, :steps => steps

class GridSequence
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

class StepHighlighter
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

# maps to an Ableton Live Impulse instrument
@kick       = GridSequence.new(60, 0, :steps => steps)
@snare      = GridSequence.new(62, 1, :steps => steps)
@rim        = GridSequence.new(64, 2, :steps => steps)
@tom        = GridSequence.new(65, 3, :steps => steps)
@closedhat  = GridSequence.new(67, 4, :steps => steps, :velocity => 70..100)
@openhat    = GridSequence.new(69, 5, :steps => steps, :velocity => 70..100)
@ride       = GridSequence.new(71, 6, :steps => steps, :velocity => 70..100)
@crash      = GridSequence.new(72, 7, :steps => steps)

@instruments = [@kick, @snare, @rim, @tom, @closedhat, @openhat, @ride, @crash]

sweeper = StepHighlighter.new(@instruments)

@beats.add_sequence sweeper

@monome = Monome.new
@instruments.each do |instrument|
  @monome.add_subgrid instrument.grid
  @beats.add_sequence instrument.sequence
  instrument.redraw
end

@s.subscribers << @beats
@s.subscribers << @monome

Signal.trap("INT") { @s.timekeeper.thread.exit!; @monome.clear; "Interrupt caught, cancelling..." }

# debugger

@s.start
@s.timekeeper.thread.join
