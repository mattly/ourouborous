module Ourouborous
  module MIDI
    module Generator
      
      attr_accessor :note_states
      
      def initialize(*a, &b)
        @note_states = Hash.new {|h, key| h[key] = nil }
      end
      
      def play(notes)
        [notes].flatten.each do |note|
          if note.start.zero?
            note_on(note.channel, note.pitch, note.velocity)
            @schedule.in(note.duration, L{ note_off(note.channel, note.pitch)})
          else
            @schedule.in(note.start, L{ note_on(note.channel, note.pitch, note.velocity) })
            @schedule.in(note.start + note.duration, L{ note_off(note.channel, note.pitch) })
          end
        end
      end
      
      def note_on(channel, pitch, velocity)
        if velocity.zero? ? playing?(channel, pitch) : ! playing?(channel, pitch)
          record_note(channel, pitch, velocity)
          @interface.note(channel, pitch, velocity)
        end
      end
      
      def note_off(channel, pitch)
        note_on(channel, pitch, 0)
      end
      
      def playing?(channel, pitch)
        ! @note_states["#{channel}x#{pitch}"].nil?
      end
      
    protected
      def record_note(channel, pitch, velocity)
        note = {:velocity => velocity}
        if @schedule && @schedule.time
          note.merge!({:started => @schedule.time})
        end
        @note_states["#{channel}x#{pitch}"] = note
      end
      
    end
  end
end