require 'rubygems'
require 'midiator'
require 'datagrammer'
require 'lib/ourouborous'
require 'lib/interfaces/midiator'
require 'lib/devices/monome'
require 'lib/instruments/monome/grid_keyboard'

require 'ruby-debug'
Debugger.start

@s = Ourouborous::Scheduler.new :timekeeper => Ourouborous::LocalTimer.new(120)

@midi = Midiator.new
@monome = Monome.new
@s.subscribers << @monome

@keyboard = GridKeyboard.new(0..15, 0..15, :interface => @midi, :channel => 3)
@monome.add_subgrid @keyboard.grid

Signal.trap("INT") { @s.timekeeper.thread.exit!; @monome.clear; "Interrupt caught, cancelling..." }

@s.start
@s.timekeeper.thread.join