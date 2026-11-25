module Vehicles
  class TankBalanceCardComponent < ApplicationComponent
    STATUS_STYLES = {
      negative: { bar_class: 'bg-red-500', num_class: 'text-red-700', chip_class: 'text-red-700 bg-red-100 border-red-200', border_class: 'border-red-200' },
      empty:    { bar_class: 'bg-red-500', num_class: 'text-red-700', chip_class: 'text-red-700 bg-red-100 border-red-200', border_class: 'border-red-200' },
      critical: { bar_class: 'bg-red-500', num_class: 'text-red-700', chip_class: 'text-red-700 bg-red-100 border-red-200', border_class: 'border-red-200' },
      low:      { bar_class: 'bg-orange-500', num_class: 'text-orange-700', chip_class: 'text-orange-700 bg-orange-100 border-orange-200', border_class: 'border-orange-200' },
      mid:      { bar_class: 'bg-amber-500', num_class: 'text-amber-700', chip_class: 'text-amber-700 bg-amber-100 border-amber-200', border_class: 'border-amber-200' },
      ok:       { bar_class: 'bg-blue-500', num_class: 'text-slate-900', chip_class: 'text-blue-700 bg-blue-50 border-blue-200', border_class: 'border-slate-100' }
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
      desktop? ? desktop_card : mobile_card
    end

    private

    def desktop?
      @variant == :desktop
    end

    def danger?
      %i[empty negative critical].include?(@status_key)
    end

    def mobile_card
      div(class: "bg-white rounded-xl shadow-sm border #{@style[:border_class]} p-4") do
        header_row
        balance_row
        progress_bar
        note_line
      end
    end

    def desktop_card
      div(class: "bg-white rounded-2xl border-2 #{@style[:border_class]} p-7") do
        header_row
        desktop_balance_row
      end
    end

    def header_row
      div(class: 'flex items-start justify-between') do
        div(class: "flex items-center #{desktop? ? 'gap-2.5' : 'gap-2'}") do
          div(class: "#{desktop? ? 'w-10 h-10 rounded-xl' : 'w-8 h-8 rounded-lg'} bg-slate-100 text-slate-600 flex items-center justify-center") do
            render PhlexIcons::Lucide::Fuel.new(class: desktop? ? 'w-5 h-5' : 'w-[17px] h-[17px]')
          end
          title_block
        end
        span(class: "text-[10px] font-bold uppercase tracking-wide rounded-full #{desktop? ? 'px-2.5' : 'px-2'} py-1 border #{@style[:chip_class]}") do
          t("vehicle.tank.status.#{@status_key}")
        end
      end
    end

    def title_block
      return h3(class: 'text-sm font-semibold text-slate-700') { t('vehicle.tank.title') } unless desktop?

      div do
        h3(class: 'text-base font-semibold text-slate-800') { t('vehicle.tank.title') }
        p(class: 'text-xs text-slate-500') { t('vehicle.tank.subtitle') }
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

    def desktop_balance_row
      div(class: 'grid grid-cols-12 gap-6 items-end mt-5') do
        div(class: 'col-span-12 lg:col-span-7') do
          p(class: "text-5xl font-bold tracking-tight tabular-nums #{@style[:num_class]}") { balance_text }
          p(class: 'text-sm text-slate-500 mt-1') { t('vehicle.tank.of_full_desktop', value: format_currency(@full || 0)) }
          div(class: 'h-2.5 bg-slate-100 rounded-full overflow-hidden mt-4') do
            div(class: "h-full rounded-full #{@style[:bar_class]}", style: "width: #{remain_pct}%")
          end
          level_line
        end
        div(class: 'col-span-12 lg:col-span-5 flex flex-col gap-2.5') do
          refuel_button(desktop: true)
          note_line
        end
      end
    end

    def balance_text
      sign = @balance.negative? ? '−' : ''
      "#{sign}#{format_currency(@balance.abs)}"
    end

    def refuel_button(desktop: false)
      tone = danger? ? 'bg-red-600 hover:bg-red-700' : 'bg-blue-600 hover:bg-blue-700'
      classes = if desktop
                  "flex items-center justify-center gap-2 rounded-xl px-4 py-2.5 text-sm font-semibold text-white #{tone}"
      else
                  "flex-shrink-0 flex items-center gap-1.5 rounded-xl px-3.5 py-2 text-xs font-semibold text-white #{tone}"
      end
      link_to(helpers.new_refueling_path, class: classes, data: { turbo_frame: 'modal' }) do
        render PhlexIcons::Lucide::Plus.new(class: desktop ? 'w-4 h-4' : 'w-[15px] h-[15px]')
        plain t("vehicle.tank.refuel#{'_desktop' if desktop}")
      end
    end

    def progress_bar
      div(class: 'h-2 bg-slate-100 rounded-full overflow-hidden mt-3') do
        div(class: "h-full rounded-full #{@style[:bar_class]}", style: "width: #{remain_pct}%")
      end
      level_line
    end

    def level_line
      key = @full.to_f.positive? ? 'vehicle.tank.level_label' : 'vehicle.tank.level_label_empty'
      params = @full.to_f.positive? ? { percent: remain_pct, remaining: format_currency([@balance, 0].max) } : {}
      p(class: 'text-[11px] text-slate-500 mt-1.5') { t(key, **params) }
    end

    def remain_pct
      return 0 unless @full.to_f.positive?

      [[(@balance.to_f / @full.to_f) * 100, 0].max, 100].min.round
    end

    def note_line
      if @status_key == :ok
        p(class: 'text-xs mt-2.5 text-slate-500') { last_fill_text }
      elsif I18n.exists?("vehicle.tank.note.#{@status_key}")
        p(class: "text-xs mt-2.5 #{@style[:num_class]}") { t("vehicle.tank.note.#{@status_key}") }
      end
    end

    def last_fill_text
      unless @last_fill
        plain t('vehicle.tank.title')
        return
      end

      return plain(t('vehicle.tank.title')) unless @last_fill.liters.present?

      plain t('vehicle.tank.last_fill', date: helpers.l(@last_fill.date, format: '%d %b'), vendor: @last_fill.vendor)
      span(class: 'text-slate-400') do
        " · #{helpers.number_with_precision(@last_fill.liters, precision: 1, separator: ',', delimiter: '.')} L · #{format_currency(@last_fill.price_per_liter)}/L"
      end
    end
  end
end
