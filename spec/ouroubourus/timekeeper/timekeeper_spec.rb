require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe Ouroubourus::Timekeeper do
  before { @t = AbstractTimer.new }
  
  it "knows how long its resolution is in seconds" do
    @t.resolution_in_seconds.should == 60 / 120.0 / 480 * 20
  end
  
  it "calls its block every time it runs" do
    i = 0
    @t.start { i += 1 }
    sleep 0.5
    i.should == 24 # (500 / (60 / 120.0 / 480 * 20 * 1000))
  end
  
  it "stops running on stop" do
    i = 0
    @t.start { i += 1 }
    sleep 0.25
    @t.stop
    sleep 0.25
    i.should == 12
  end
end