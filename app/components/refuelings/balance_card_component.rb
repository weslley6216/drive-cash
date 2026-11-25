module Refuelings
  class BalanceCardComponent < ApplicationComponent
    def initialize(balance:, full:, since:, variant: :mobile)
      @balance = balance
      @full = full
      @since = since
      @variant = variant
      @status_key = Vehicles::TankStatus.for(balance, full)
      @style = Vehicles::TankBalanceCardComponent::STATUS_STYLES.fetch(@status_key)
    end

    def view_template
      desktop? ? desktop_card : mobile_card
    end

    private

    def desktop?
      @variant == :desktop
    end

    def mobile_card
      div(class: 'bg-white rounded-xl shadow-sm border border-slate-100 p-4') do
        div(class: 'flex items-end justify-between gap-3') do
          div do
            label_line
            value_line('text-2xl font-bold tracking-tight tabular-nums mt-0.5')
          end
          p(class: 'text-xs text-slate-500 text-right') do
            plain t('vehicle.moves.balance.of_full', amount: format_currency(@full))
            br
            plain t('vehicle.moves.balance.since', date: date_text)
          end
        end
        bar('h-1.5', 'mt-3')
      end
    end

    def desktop_card
      div(class: 'bg-white rounded-xl border border-slate-200 p-5') do
        label_line
        value_line('text-4xl font-bold tracking-tight tabular-nums mt-1')
        p(class: 'text-sm text-slate-500 mt-1') { t('vehicle.moves.balance.of_full_since', amount: format_currency(@full), date: date_text) }
        bar('h-2', 'mt-4')
      end
    end

    def label_line
      p(class: 'text-[11px] font-semibold text-slate-400 uppercase tracking-wider') { t('vehicle.moves.balance.label') }
    end

    def value_line(classes)
      p(class: "#{classes} #{@style[:num_class]}") { balance_text }
    end

    def balance_text
      sign = @balance.negative? ? '−' : ''
      "#{sign}#{format_currency(@balance.abs)}"
    end

    def bar(height, margin)
      div(class: "#{height} bg-slate-100 rounded-full overflow-hidden #{margin}") do
        div(class: "h-full rounded-full #{@style[:bar_class]}", style: "width: #{remain_pct}%")
      end
    end

    def remain_pct
      return 0 unless @full.to_f.positive?

      [[(@balance.to_f / @full.to_f) * 100, 0].max, 100].min.round
    end

    def date_text
      helpers.l(@since, format: '%d %b')
    end
  end
end
