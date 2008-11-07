module Ourouborous
  module MIDI
    module Generator
      
      attr_accessor :note_states
      
      VALID_PITCHES = 0..127
      
      # def initialize(*a, &b)
        # super wtf?
      def setup_notes
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
        return unless VALID_PITCHES.include?(pitch)
        record_note(channel, pitch, velocity)
        @interface.note(channel, pitch, velocity)
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