#! /usr/bin/env ruby
# requires a monome 256, monomeSerial running, sending on /monome to port 8000 and listening on 8080

tempo = 96

require 'rubygems'
require 'midiator'
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
@beats = StepSequencer.new :interface => @midi

class GridSequence
  attr_accessor :grid, :sequence
  
  def initialize(pitch, row, options)
    @sequence = StepSequencer::Sequence.new(pitch, options)
    @grid = Monome::Grid.new(0..15, row, L{|c,r,v,g| toggle(c,v) })
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

@kick     = GridSequence.new(60, 0, :sequence => %w(1 0 1 0 0 0 0 0 1 0 1 1 0 1 0 0))
@snare    = GridSequence.new(62, 1, :sequence => %w(0 0 0 0 1 0 0 0 0 0 0 0 1 0 0 0))
@hats     = GridSequence.new(71, 2, :sequence => %w(0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1), :velocity => 80..100)
@instruments = [@kick, @snare, @hats]
@beats.sequences = @instruments.map {|i| i.sequence }
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