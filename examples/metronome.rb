#! /usr/bin/env ruby

tempo = 96
# comment this out and choose another one below if you want
# a second metronome is set to run an octave and a half below at 8/8
signature = [4,4]
# signature = [3,4]
# signature = [5,4]
# signature = [6,4]
# signature = [7,8]
# signature = [11,8]

require 'rubygems'
require 'midiator'
require 'lib/ourouborous'
require 'lib/interfaces/midiator'
require 'lib/sequencers/metronome'

require 'ruby-debug'
Debugger.start

@s = Ourouborous::Scheduler.new :timekeeper => Ourouborous::LocalTimer.new(tempo)
@midi = Midiator.new
@midi.interface.autodetect_driver
@midi.interface.program_change 0, 115 # wood block
@metronome1 = Metronome.new :interface => @midi, :signature => signature
@metronome2 = Metronome.new :interface => @midi, :signature => [8,8], :basenote => 53
@s.subscribers << @metronome1
@s.subscribers << @metronome2

Signal.trap("INT") { @s.timekeeper.thread.exit!; "Interrupt caught, cancelling..." }

# debugger

@s.start
@s.timekeeper.thread.join