module Vehicles
  class TankBalanceCardComponent < ApplicationComponent
    STATUS_STYLES = {
      negative: { bar_class: 'bg-red-500', num_class: 'text-red-700', chip_class: 'text-red-700 bg-red-100 border-red-200' },
      empty:    { bar_class: 'bg-red-500', num_class: 'text-red-700', chip_class: 'text-red-700 bg-red-100 border-red-200' },
      low:      { bar_class: 'bg-amber-500', num_class: 'text-amber-700', chip_class: 'text-amber-700 bg-amber-100 border-amber-200' },
      ok:       { bar_class: 'bg-blue-500', num_class: 'text-slate-900', chip_class: 'text-blue-700 bg-blue-50 border-blue-200' }
    }.freeze

    def initialize(balance:, full:, last_fill:, variant: :mobile)
      @balance = balance
      @full = full
      @last_fill = last_fill
      @variant = variant
      @status_key = Vehicles::TankStatus.for(balance, full)
      @style = STATUS_STYLES.fetch(@status_key)
    end

    def view_template
      div(class: card_classes) do
        header_row
        balance_row
        progress_bar
        note_line
      end
    end

    private

    def danger?
      %i[empty negative].include?(@status_key)
    end

    def card_classes
      border = if danger?
                 'border-red-200'
      else
                 @status_key == :low ? 'border-amber-200' : 'border-slate-100'
      end
      "bg-white rounded-2xl border #{border} p-4"
    end

    def header_row
      div(class: 'flex items-center justify-between mb-2') do
        div(class: 'flex items-center gap-2') do
          div(class: 'w-8 h-8 rounded-lg bg-slate-100 text-slate-600 flex items-center justify-center') do
            render PhlexIcons::Lucide::Fuel.new(class: 'w-[17px] h-[17px]')
          end
          h3(class: 'text-sm font-semibold text-slate-700') { t('vehicle.tank.title') }
        end
        span(class: "text-[10px] font-bold uppercase tracking-wide rounded-full px-2 py-1 border #{@style[:chip_class]}") do
          t("vehicle.tank.status.#{@status_key}")
        end
      end
    end

    def balance_row
      div(class: 'flex items-end justify-between gap-3') do
        div(class: 'min-w-0') do
          p(class: "text-3xl font-bold tracking-tight tabular-nums #{@style[:num_class]}") { balance_text }
          p(class: 'text-xs text-slate-500 mt-0.5') { t('vehicle.tank.of_full', value: format_currency(@full || 0)) }
        end
        refuel_button
      end
    end

    def balance_text
      sign = @balance.negative? ? '−' : ''
      "#{sign}#{format_currency(@balance.abs)}"
    end

    def refuel_button
      tone = danger? ? 'bg-red-600 hover:bg-red-700' : 'bg-blue-600 hover:bg-blue-700'
      link_to(helpers.new_refueling_path,
              class: "flex-shrink-0 flex items-center gap-1.5 rounded-xl px-3.5 py-2 text-xs font-semibold text-white #{tone}",
              data:  { turbo_frame: 'modal' }) do
        render PhlexIcons::Lucide::Plus.new(class: 'w-[15px] h-[15px]')
        plain t('vehicle.tank.refuel')
      end
    end

    def progress_bar
      div(class: 'h-2 bg-slate-100 rounded-full overflow-hidden mt-3') do
        div(class: "h-full rounded-full #{@style[:bar_class]}", style: "width: #{remain_pct}%")
      end
    end

    def remain_pct
      return 0 unless @full.to_f.positive?

      [[(@balance.to_f / @full.to_f) * 100, 0].max, 100].min.round
    end

    def note_line
      if @status_key == :ok
        p(class: 'text-xs mt-2.5 text-slate-500') { last_fill_text }
      else
        p(class: "text-xs mt-2.5 #{@style[:num_class]}") { t("vehicle.tank.note.#{@status_key}") }
      end
    end

    def last_fill_text
      unless @last_fill
        plain t('vehicle.tank.title')
        return
      end

      plain t('vehicle.tank.last_fill', date: helpers.l(@last_fill.date, format: '%d %b'), vendor: @last_fill.vendor)
      span(class: 'text-slate-400') do
        " · #{helpers.number_with_precision(@last_fill.liters, precision: 1, separator: ',', delimiter: '.')} L · #{format_currency(@last_fill.price_per_liter)}/L"
      end
    end
  end
end
