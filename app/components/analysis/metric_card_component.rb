module Analysis
  class MetricCardComponent < ApplicationComponent
    def initialize(label:, icon:, value:, hint: nil, change_pct: nil, pp: false)
      @label = label
      @icon = icon
      @value = value
      @hint = hint
      @change_pct = change_pct
      @pp = pp
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
      label = @pp ? "#{sign}#{@change_pct.abs} p.p. vs anterior" : "#{sign}#{@change_pct.abs}% vs anterior"
      p(class: "text-xs font-medium mt-0.5 #{color}") { label }
    end
  end
end
