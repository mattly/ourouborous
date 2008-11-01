#! /usr/bin/env ruby

tempo = 96
require 'rubygems'
require 'midiator'
require 'lib/ouroubourus'
require 'lib/interfaces/midiator'
require 'lib/sequencers/step_sequencer'

require 'ruby-debug'
Debugger.start

@s = Ouroubourus::Scheduler.new :timekeeper => Ouroubourus::LocalTimer.new(tempo)
@midi = Midiator.new
@midi.interface.autodetect_driver
@midi.interface.program_change 0, 115 # wood block
@midi.interface.driver.instance_variable_set(:@destination, MIDIator::Driver::CoreMIDI::C.mIDIGetDestination(1)) # ugly hack for now
@beats = StepSequencer.new :interface => @midi
@beats.sequences << StepSequencer::Sequence.new(60, :sequence => %w(1 0 0 0.25 0 0 0 0    1 0 0.75 0 0 0.9 0   0.5))
@beats.sequences << StepSequencer::Sequence.new(62, :sequence => %w(0 0 0 0    1 0 0 0.33 0 0 0    0 1 0   0.5 0.5))
@s.subscribers << @beats

Signal.trap("INT") { @s.timekeeper.thread.exit!; "Interrupt caught, cancelling..." }

# debugger

@s.start
@s.timekeeper.thread.join