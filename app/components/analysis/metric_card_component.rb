module Analysis
  class MetricCardComponent < ApplicationComponent
    def initialize(label:, icon:, value:, hint: nil, change_pct: nil, pp: false, period_label: nil)
      @label = label
      @icon = icon
      @value = value
      @hint = hint
      @change_pct = change_pct
      @pp = pp
      @period_label = period_label
    end

    def view_template
      div(class: 'bg-white rounded-xl shadow-sm border border-slate-100 p-4') do
        div(class: 'flex items-center gap-2 text-slate-500 mb-1') do
          render @icon.new(class: 'lucide w-[14px] h-[14px]')
          span(class: 'text-xs font-medium') { @label }
        end
        p(class: 'text-xl font-bold text-slate-800') { @value }
        change_badge if @change_pct
        p(class: 'text-[10px] text-slate-400 mt-0.5') { @hint } if @hint
      end
    end

    private

    def change_badge
      positive = @change_pct.to_f >= 0
      color = positive ? 'text-emerald-600' : 'text-red-600'
      sign = positive ? '+' : '−'
      label = "#{sign}#{@change_pct.abs}#{badge_suffix}"
      p(class: "text-xs font-medium mt-0.5 #{color}") { label }
    end

    def badge_suffix
      if @period_label
        @pp ? " p.p. #{@period_label}" : "% #{@period_label}"
      else
        suffix_key = @pp ? 'analysis.show_view.metrics.vs_previous_pp' : 'analysis.show_view.metrics.vs_previous'
        I18n.t(suffix_key)
      end
    end
  end
end
