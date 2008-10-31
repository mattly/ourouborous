#! /usr/bin/env ruby

tempo = 96
# comment this out and choose another one below if you want
signature = [4,4]
# signature = [3,4]
# signature = [5,4]
# signature = [6,4]
# signature = [7,8]
# signature = [11,8]

require 'rubygems'
require 'midiator'
require 'lib/ouroubourus'
require 'lib/sequencers/metronome'

@s = Ouroubourus::Scheduler.new :timekeeper => Ouroubourus::LocalTimer.new(tempo, :resolution => 80)
@midi = MIDIator::Interface.new
@midi.autodetect_driver
@midi.program_change 0, 115 # wood block
@metronome1 = Metronome.new :interface => @midi, :signature => signature
@metronome2 = Metronome.new :interface => @midi, :signature => [6,4], :basenote => 67
@s.subscribers << @metronome1
@s.subscribers << @metronome2

Signal.trap("INT") { @s.timekeeper.thread.exit!; "Interrupt caught, cancelling..." }

@s.start
@s.timekeeper.thread.join