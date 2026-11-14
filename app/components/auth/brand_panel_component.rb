class Auth::BrandPanelComponent < ApplicationComponent
  def view_template
    div(
      class: 'hidden lg:flex w-[46%] flex-col justify-between p-12 relative overflow-hidden',
      style: 'background: linear-gradient(150deg,#1d4ed8 0%,#2563eb 55%,#3b82f6 100%)'
    ) do
      render BrandMarkComponent.new(light: true)
      hero_block
      p(class: 'text-xs text-blue-200/80') { t('.copyright') }
    end
  end

  private

  def hero_block
    div(class: 'relative') do
      h2(class: 'text-4xl font-bold text-white tracking-tight leading-[1.15]') do
        plain t('.headline_line1')
        br
        plain t('.headline_line2')
      end
      p(class: 'text-base text-blue-100 mt-4 max-w-sm leading-relaxed') { t('.subheadline') }
      hero_profit_card
    end
  end

  def hero_profit_card
    div(class: 'mt-8 inline-flex items-center gap-4 bg-white/10 backdrop-blur rounded-2xl px-5 py-4 border border-white/15') do
      div(class: 'w-11 h-11 rounded-xl bg-white/15 flex items-center justify-center text-white') do
        render PhlexIcons::Lucide::TrendingUp.new(class: 'w-5 h-5')
      end
      div do
        p(class: 'text-[11px] font-semibold uppercase tracking-wider text-blue-100') { t('.hero_profit_label') }
        p(class: 'text-2xl font-bold text-white tabular-nums tracking-tight mt-0.5') { format_currency(16_555.27) }
      end
    end
  end
end
