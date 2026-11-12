module Goals
  class AnnualBarComponent < ApplicationComponent
    include CardStyles

    DAYS_PER_MONTH = 30

    def initialize(progress:)
      @progress = progress
    end

    def view_template
      div(class: "#{CARD} #{DESKTOP_FLAT} p-4 lg:p-5") do
        header
        phone_body
        desktop_body
      end
    end

    private

    def header
      div(class: 'flex items-center justify-between mb-3') do
        div(class: 'flex items-center gap-2') do
          div(class: 'w-8 h-8 rounded-full bg-purple-100 flex items-center justify-center text-purple-600') do
            render PhlexIcons::Lucide::Star.new(class: 'w-4 h-4 lg:w-3.5 lg:h-3.5')
          end
          div do
            p(class: 'text-sm font-semibold text-slate-800') do
              span(class: 'lg:hidden') { t('goals.index.annual.label') }
              span(class: 'hidden lg:inline') { t('goals.index.annual.label_desktop') }
            end
            p(class: 'text-xs text-slate-500') do
              span(class: 'lg:hidden') { t('goals.index.annual.metric_year', metric: metric_name, year: year) }
              span(class: 'hidden lg:inline') { year.to_s }
            end
          end
        end
        edit_link
      end
    end

    def phone_body
      div(class: 'lg:hidden') do
        div(class: 'flex items-baseline justify-between mb-2') do
          span(class: 'text-xl font-bold text-slate-800') { format_currency(@progress[:current]) }
          span(class: 'text-sm text-slate-500') { of_target }
        end
        bar('mb-2')
        p(class: 'text-xs text-slate-500') do
          span(class: 'font-medium text-purple-700') { percent_label }
          plain " · #{t('goals.index.annual.months_left', count: months_remaining)}"
        end
      end
    end

    def desktop_body
      div(class: 'hidden lg:block') do
        p(class: 'text-2xl font-bold text-slate-900 tabular-nums mt-2') { format_currency(@progress[:current]) }
        p(class: 'text-xs text-slate-500') { of_target }
        bar('mt-3')
        p(class: 'text-xs text-purple-700 font-medium mt-2') do
          plain "#{percent_label} · #{t('goals.index.annual.remaining_months', count: months_remaining)}"
        end
      end
    end

    def bar(spacing)
      div(class: "h-2 bg-slate-100 rounded-full overflow-hidden #{spacing}") do
        div(class: 'h-full bg-gradient-to-r from-purple-400 to-purple-600 rounded-full', style: "width: #{width}%")
      end
    end

    def edit_link
      goal = @progress[:goal]
      return if goal.ended?

      link_to(helpers.edit_goal_path(goal),
              class: 'w-7 h-7 rounded-full bg-white border border-slate-200 flex items-center justify-center text-slate-500 hover:text-slate-700',
              aria:  { label: t('goals.index.edit_aria') },
              data:  { turbo_frame: 'modal' }) do
        render PhlexIcons::Lucide::Pencil.new(class: 'w-[14px] h-[14px]')
      end
    end

    def of_target
      t('goals.index.annual.of_target', target: format_currency(@progress[:target]))
    end

    def percent_label
      "#{format_percentage(@progress[:percent].to_f)}%"
    end

    def width
      @progress[:percent].to_f.clamp(0, 100).round
    end

    def metric_name
      t("goals.index.form.metrics.#{@progress[:goal].metric}")
    end

    def year
      @progress[:goal].period_start.year
    end

    def months_remaining
      (@progress[:days_remaining].to_f / DAYS_PER_MONTH).round
    end
  end
end
