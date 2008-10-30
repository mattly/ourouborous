alias :L :lambda

module Ouroubourus
  
end

$:.unshift File.dirname(__FILE__)
%w(scheduler schedulable schedule
timekeeper/timekeeper timekeeper/local_timer
).each {|r| require "ouroubourus/#{r}.rb" }
