require 'rubygems'

gem 'rspec'
require 'spec'

gem 'ruby-debug'
require 'ruby-debug'

require "#{File.dirname(__FILE__)}/../lib/ouroubourus"

Debugger.start

class AbstractSchedule
  attr_accessor :time
  def run(now)
    @time = now
  end
end

class AbstractTimer
  include Ouroubourus::Timekeeper
  def initialize
    @tempo = 120
    @resolution = 20
    @run = L do |b| 
      loop do 
        b.call(Time.now)
        sleep resolution_in_seconds
      end
    end
  end
end
