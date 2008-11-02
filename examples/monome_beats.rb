#! /usr/bin/env ruby
# requires a monome, monomeSerial running, sending on /monome to port 8000 and listening on 8080
# also requires datagrammer, gem install mattly-datagrammer from github

tempo = 96
steps = 16   # 40h or 64 users! change to 8

require 'rubygems'
require 'midiator'
require 'datagrammer'
require 'lib/ouroubourus'
require 'lib/interfaces/midiator'
require 'lib/devices/monome'
require 'lib/sequencers/step_sequencer'

require 'ruby-debug'
Debugger.start

@s = Ouroubourus::Scheduler.new :timekeeper => Ouroubourus::LocalTimer.new(tempo)
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
    @grid = Monome::Grid.new(0..(@steps-1), row, L{|c,r,v| toggle(c,v) })
  end
  
  def toggle(col, val)
    return if val.zero?
    val = @sequence.get(col).zero?? 1 : 0
    @sequence.set(col, val)
    redraw
  end
  
  def redraw
    @sequence.sequence.each_with_index {|val, step| @grid.led(step, 0, val)}
  end
end

class StepHighlighter
  attr_accessor :instruments
  def initialize(instruments)
    @instruments = instruments
  end
  
  def offs(step)
    @instruments.select {|i| i.sequence.get(step).zero? }
  end
  
  def run(step)
    offs(step).each {|i| i.grid.on(step,0) }
    [20, L{ offs(step).each {|i| i.grid.off(step,0) } }]
  end
end

# maps to an Ableton Live Impulse instrument
@kick       = GridSequence.new(60, 0, :steps => steps, :sequence => %w(1 0 0 0) * 4)
@snare      = GridSequence.new(62, 1, :steps => steps)
@rim        = GridSequence.new(64, 2, :steps => steps)
@tom        = GridSequence.new(65, 3, :steps => steps)
@closedhat  = GridSequence.new(67, 4, :steps => steps, :velocity => 70..100, :sequence => %w(1 0) * 8)
@openhat    = GridSequence.new(69, 5, :steps => steps, :velocity => 70..100, :sequence => %w(0 1) * 8)
@ride       = GridSequence.new(71, 6, :steps => steps, :velocity => 70..100)
@crash      = GridSequence.new(72, 7, :steps => steps)

@instruments = [@kick, @snare, @rim, @tom, @closedhat, @openhat, @ride, @crash]

sweeper = StepHighlighter.new(@instruments)

@beats.sequences = @instruments.map {|i| i.sequence }
@beats.sequences << sweeper
@s.subscribers << @beats

@monome = Monome.new
@instruments.each do |instrument|
  @monome.add_subgrid instrument.grid
  instrument.redraw
end

Signal.trap("INT") { @s.timekeeper.thread.exit!; @monome.clear; "Interrupt caught, cancelling..." }

# debugger

@s.start
@s.timekeeper.thread.join