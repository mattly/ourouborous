require 'datagrammer'
class Monome
  
  attr_accessor :listener, :areas, :grids
  
  def initialize(options={})
    @host_port = options[:host_port] || 8080
    @listener = Datagrammer.new(8000, :speak_port => @host_port)
    @listener.listen {|dg, data| self.send(data.shift.sub('/monome/',''), *data) }
    @grids = []
  end
  
  def add_subgrid(grid)
    raise StandardException unless grid.kind_of?(Monome::Grid)
    grid.parent = self
    @grids << grid
  end
  
  def press(col, row, val)
    grid = @grids.detect {|g| g.target?(col, row) }
    grid.press(col, row, val) if grid
  end
  
  def clear
    @listener.speak(['/monome/clear'])
  end
  
  def led(col, row, val)
    @listener.speak(['/monome/led', col, row, val])
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
      @blinks = Array.new(@colcount) { Array.new(@rowcount) }
      @leds = {}
      @press = press || L{|c,r,v,s| s.led(c,r,v) }
      clear
    end
    
    def target?(col, row)
      @cols.include?(col) && @rows.include?(row)
    end
    
    def press(col, row, val)
      col = col - @offset.first
      row = row - @offset.last
      @press.call(col, row, val, self)
    end
    
    def blink(col, row, rate=0.5, percent=0.5)
      percent = [0.1, [0.9, percent].min].max
      @blinks[col][row] = Thread.start do
        loop do
          on(col, row)
          sleep rate * percent
          off(col, row)
          sleep rate * (1-percent)
        end
      end
    end
    
    def toggle(col, row)
      @leds[col][row] ? off(col, row) : on(col, row)
    end
    
    def on(col, row)
      led(col, row, 1)
    end
    
    def off(col, row)
      led(col, row, 0)
    end
    
    def clear
      cols.each {|col| rows.each {|row| off(col, row) }}
    end
    
    def led(col, row, val)
      @leds["#{col}x#{row}"] = !val.zero?
      col = col + @offset.first
      row = row + @offset.last
      @parent.led(col, row, val)
    end
  end
  
end