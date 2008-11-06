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
require 'lib/instruments/monome/step_grid'

require 'ruby-debug'
Debugger.start

@s = Ourouborous::Scheduler.new :timekeeper => Ourouborous::LocalTimer.new(tempo)


@midi = Midiator.new
# @midi.interface.driver.instance_variable_set(:@destination, MIDIator::Driver::CoreMIDI::C.mIDIGetDestination(0)) # ugly hack for now

@monome = Monome.new

@beatbox = StepGrid.new(0, [60, 62, 64, 65, 67, 69, 71, 72], 
  :interface => @midi, 
  :steps => 16, 
  :monome => @monome,
  :sequences => [
    {:sequence => %w(1 0 0 0 0 0 0 0) * 2}, {:sequence => %w(0 0 0 0 1 0 0 0) * 2}, {}, {}, 
    {:velocity => 70..100}, {:velocity => 70..100}, {:velocity => 70..100}, {:velocity => 115..127}])

@s.subscribers << @beatbox.sequencer
@s.subscribers << @monome

Signal.trap("INT") { @s.timekeeper.thread.exit!; @monome.clear; "Interrupt caught, cancelling..." }

@s.start
@s.timekeeper.thread.join
