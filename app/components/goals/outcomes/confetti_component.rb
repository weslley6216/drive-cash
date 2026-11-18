module Goals
  module Outcomes
    class ConfettiComponent < ApplicationComponent
      PIECES = 64
      PHONE_PIECES = 42
      SEED = 7
      COLORS = ['#10b981', '#2563eb', '#f59e0b', '#6366f1', '#ef4444', '#fbbf24'].freeze

      def view_template
        div(class: 'dc-confetti', aria: { hidden: 'true' }) do
          pieces.each_with_index do |piece, index|
            i(class: class_names(('hidden lg:block' if index >= PHONE_PIECES)), style: piece_style(piece))
          end
        end
      end

      private

      def pieces
        x = SEED
        rnd = -> { x = (x * 9301 + 49297) % 233280; x / 233280.0 }
        Array.new(PIECES) do |index|
          {
            left:  rnd.call * 100,
            w:     6 + rnd.call * 5,
            h:     8 + rnd.call * 8,
            color: COLORS[index % COLORS.length],
            dur:   2.4 + rnd.call * 1.2,
            delay: rnd.call * 0.6,
            dx:    (rnd.call - 0.5) * 120,
            rot:   360 + rnd.call * 540,
            round: rnd.call > 0.7
          }
        end
      end

      def piece_style(piece)
        height = piece[:round] ? piece[:w] : piece[:h]
        radius = piece[:round] ? 999 : 2
        "left: #{piece[:left]}%; width: #{piece[:w]}px; height: #{height}px; background: #{piece[:color]}; " \
          "border-radius: #{radius}px; --dur: #{piece[:dur]}s; --delay: #{piece[:delay]}s; " \
          "--dx: #{piece[:dx]}px; --rot: #{piece[:rot]}deg"
      end
    end
  end
end
