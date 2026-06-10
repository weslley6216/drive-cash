class Vehicle
  class InsightCardComponent < ApplicationComponent
    def initialize(insight:)
      @insight = insight
    end

    def view_template
      div(class: 'rounded-2xl bg-blue-50 border border-blue-200 p-4 flex items-start gap-3') do
        div(class: 'w-9 h-9 rounded-full bg-blue-400/30 flex items-center justify-center flex-shrink-0') do
          render PhlexIcons::Lucide::Zap.new(class: 'w-4 h-4 text-blue-700')
        end
        div(class: 'min-w-0') do
          p(class: 'text-sm font-semibold text-blue-900') { @insight[:title] }
          p(class: 'text-xs text-blue-800 mt-0.5 leading-relaxed') { @insight[:description] }
        end
      end
    end
  end
end
