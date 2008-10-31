module Ouroubourus
  module MIDI
    module Generator
      
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
        @interface.note(channel, pitch, velocity)
      end
      
      def note_off(channel, pitch)
        note_on(channel, pitch, 0)
      end
      
    end
  end
end