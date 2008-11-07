tempo = 120
steps = 16   # 40h or 64 users! change to 8

keyboard_channel = 2
keyboard_basenote = 36

require 'rubygems'
require 'midiator'
require 'datagrammer'
require 'lib/ourouborous'
require 'lib/interfaces/osc_midi'
require 'lib/devices/monome'
require 'lib/instruments/monome/grid_keyboard'
require 'lib/instruments/monome/step_grid'

@gram = Datagrammer.new(8000)

@midi = OscMidi.new(:speaker => @gram)
@monome = Monome.new(:listener => @gram)

@scheduler = Ourouborous::Scheduler.new :timekeeper => Ourouborous::LocalTimer.new(tempo)
@scheduler.subscribers << @monome

@beatbox = StepGrid.new(0, [60, 62, 64, 65, 67, 69, 71, 72], 
  :interface => @midi, 
  :steps => 16, 
  :monome => @monome,
  :sequences => [
    {:sequence => %w(1 0 1 0 0 0 0 0 1 0 0 1 0 0 0 0)}, {:sequence => %w(0 0 0 0 1 0 0 0) * 2}, {}, {}, 
    {:velocity => 70..100}, {:velocity => 70..100}, {:velocity => 70..100}, {:velocity => 115..127}])

@scheduler.subscribers << @beatbox.sequencer

@keyboard = GridKeyboard.new(0..15, 8..15, :basenote => keyboard_basenote, :interface => @midi, :channel => keyboard_channel)
@monome.add_subgrid @keyboard.grid

Signal.trap("INT") { @scheduler.timekeeper.thread.exit!; @monome.clear; "Interrupt caught, cancelling..." }

@scheduler.start
@scheduler.timekeeper.thread.join