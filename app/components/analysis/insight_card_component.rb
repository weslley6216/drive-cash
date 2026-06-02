module Analysis
  class InsightCardComponent < ApplicationComponent
    def initialize(insight:)
      @insight = insight
    end

    def view_template
      div(class: 'rounded-2xl bg-amber-50 border border-amber-200 p-4 flex items-start gap-3') do
        div(class: 'w-9 h-9 rounded-full bg-amber-400/30 flex items-center justify-center shrink-0') do
          render PhlexIcons::Lucide::Flame.new(class: 'w-[18px] h-[18px] text-amber-600')
        end
        div(class: 'min-w-0') do
          p(class: 'text-sm font-semibold text-amber-900') { @insight[:title] }
          p(class: 'text-xs text-amber-800 mt-0.5 leading-relaxed') { @insight[:description] }
        end
      end
    end
  end
end
