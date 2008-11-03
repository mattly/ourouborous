alias :L :lambda

module Ourouborous
  
end

$:.unshift File.dirname(__FILE__)
%w(scheduler schedulable schedule
midi midi/note midi/generator
timekeeper/timekeeper timekeeper/local_timer
).each {|r| require "ourouborous/#{r}.rb" }
