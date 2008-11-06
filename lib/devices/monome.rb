require 'datagrammer'

class Monome
  include Ourouborous::Schedulable
  
  attr_accessor :listener, :areas, :grids
  
  def initialize(options={})
    super
    @monome_serial = {
      :port => options[:return_port] || 8080,
      :address => options[:return_address] || "0.0.0.0"
    }
    @prefix = "/#{(options[:prefix] || 'monome')}".gsub('//','/')
    
    @listener = options[:listener] || Datagrammer.new(options[:port] || 8000)
    @listener.register_rule "#{@prefix}/press", L{|args| press(*args) }
    
    @grids = []
    clear
  end
  
  def add_subgrid(grid)
    grid.parent = self
    @grids << grid
  end
  
  def press(col, row, val)
    @grids.select {|g| g.target?(col, row) }.each {|g| g.press(col, row, val) }
  end
  
  def clear
    speak "#{@prefix}/clear"
  end
  
  def led(col, row, val)
    speak "#{@prefix}/led", col, row, val
  end
  
  def speak(*message)
    @lisener.speak(message, @monome_serial[:address], @monome_serial[:port])
  end
  
end

$:.unshift File.dirname(__FILE__)
%w(grid).each {|r| require "monome/#{r}" }