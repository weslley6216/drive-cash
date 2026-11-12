module Analysis
  class InsightCardComponent < ApplicationComponent
    def initialize(insight:)
      @insight = insight
    end

    def view_template
      div(class: 'rounded-2xl lg:rounded-xl bg-amber-50 border border-amber-200 p-4 lg:p-5 flex items-start gap-3 lg:gap-4') do
        div(class: 'w-9 h-9 lg:w-11 lg:h-11 rounded-full bg-amber-400/30 flex items-center justify-center shrink-0') do
          render PhlexIcons::Lucide::Flame.new(class: 'w-[18px] h-[18px] lg:w-5 lg:h-5 text-amber-600 lg:text-amber-700')
        end
        div(class: 'min-w-0') do
          p(class: 'text-sm font-semibold text-amber-900') { @insight[:title] }
          p(class: 'text-xs lg:text-sm text-amber-800 mt-0.5 lg:mt-1 leading-relaxed') { @insight[:description] }
        end
      end
    end
  end
end
