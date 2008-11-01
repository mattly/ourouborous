#! /usr/bin/env ruby

tempo = 96

kick_probability  = %w(1.00 0.00 0.00 0.25 0.00 0.25 0.00 0.00 1.00 0.00 0.75 0.00 0.00 0.90 0.00 0.50)
snare_probability = %w(0.00 0.00 0.00 0.00 1.00 0.00 0.00 0.33 0.00 0.00 0.00 0.00 1.00 0.00 0.50 0.50)
hihat_probability = %w(0.9 0.1) * 8
crash_probability = [0] * 15 << 0.25

kick_accent       = [95..105, 70..80] * 8
snare_accent      = [90..110, 70..80, 80..90, 70..80] * 4
hihat_accent      = [80..100, 40..60] * 8

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
# maps to an ableton impulse instrument
@beats.sequences << StepSequencer::Sequence.new(60, :sequence => kick_probability, :velocity => kick_accent)
@beats.sequences << StepSequencer::Sequence.new(62, :sequence => snare_probability, :velocity => snare_accent)
@beats.sequences << StepSequencer::Sequence.new(71, :sequence => hihat_probability, :velocity => hihat_accent)
@beats.sequences << StepSequencer::Sequence.new(72, :sequence => crash_probability)
@s.subscribers << @beats

Signal.trap("INT") { @s.timekeeper.thread.exit!; "Interrupt caught, cancelling..." }

# debugger

@s.start
@s.timekeeper.thread.join