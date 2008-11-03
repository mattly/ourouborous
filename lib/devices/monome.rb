require 'datagrammer'
class Monome
  include Ourouborous::Schedulable
  
  attr_accessor :listener, :areas, :grids
  
  def initialize(options={})
    super
    @host_port = options[:host_port] || 8080
    @prefix = "/#{(options[:prefix] || 'monome')}".gsub('//','/')
    @listener = Datagrammer.new(8000, :speak_port => @host_port)
    @listener.listen {|dg, data| self.send(data.shift.sub("#{@prefix}/",''), *data) }
    @grids = []
    clear
  end
  
  def add_subgrid(grid)
    raise "that ain't no grid" unless grid.kind_of?(Monome::Grid)
    grid.parent = self
    @grids << grid
  end
  
  def press(col, row, val)
    @grids.select {|g| g.target?(col, row) }.each {|g| g.press(col, row, val) }
  end
  
  def clear
    @listener.speak(["#{@prefix}/clear"])
  end
  
  def led(col, row, val)
    @listener.speak(["#{@prefix}/led", col, row, val])
  end
  
  class Grid
    attr_accessor :parent, :blinks, :leds
    
    def initialize(cols, rows, press=nil)
      cols = cols..cols if cols.kind_of?(Integer)
      rows = rows..rows if rows.kind_of?(Integer)
      @offset = [cols.first, rows.first]
      @colcount = cols.last - cols.first
      @rowcount = rows.last - rows.first
      @cols = cols
      @rows = rows
      @states = Hash.new {|h,k| h[k] = {:led => false, :pressed => false, :blinking => false} }
      @press = press || L{|c,r,v,s| s.led(c,r,v) }
    end
    
    def state(col, row)
      @states["#{col}x#{row}"]
    end
    
    def target?(col, row)
      @cols.include?(col) && @rows.include?(row)
    end
    
    def press(col, row, val)
      col = col - @offset.first
      row = row - @offset.last
      state(col, row)[:pressed] = val.nonzero?
      @press.call(col, row, val)
    end
    
    def blink(col, row, period=480, percent=0.5)
      already_blinking = blinking?(col, row)
      state(col, row)[:blinking] = {:period => period, :percent => percent}
      blink_on(col, row) unless already_blinking
    end
    
    def blinking?(col, row)
      state(col, row)[:blinking]
    end
    
    def blink_on(col, row)
      if blink = state(col, row)[:blinking]
        led(col, row, 1)
        @parent.schedule.in((blink[:period] * blink[:percent]), L{|now| blink_off(col, row) })
      end
    end
    
    def blink_off(col, row)
      if blink = state(col, row)[:blinking]
        led(col, row, 0)
        @parent.schedule.in((blink[:period] * (1-blink[:percent])), L{|now| blink_on(col, row) })
      end
    end
    
    def stop_blinking(col, row)
      if blinking?(col, row)
        state(col, row)[:blinking] = false
      end
    end
    
    def on(col, row)
      stop_blinking(col, row)
      led(col, row, 1)
    end
    
    def off(col, row)
      stop_blinking(col, row)
      led(col, row, 0)
    end
    
    def clear
      cols.each {|col| rows.each {|row| off(col, row) }}
    end
    
    def led(col, row, val)
      state(col, row)[:led] = val.nonzero?
      col = col + @offset.first
      row = row + @offset.last
      @parent.led(col, row, val)
    end
  end
  
end