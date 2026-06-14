module Goals
  class IndexView < ApplicationComponent
    def initialize(progress:, filters: {})
      @progress = progress
      @filters = filters
    end

    def view_template
      render LayoutComponent.new(title: t('goals.index.title'), bottom_nav: :goals, sidebar_nav: :goals) do
        div(id: 'flash') { render FlashComponent.new(flash: helpers.flash) }

        header_section
        if any_goal?
          hero_section
          columns_section
        else
          render Goals::EmptyStateComponent.new
        end

        turbo_frame_tag 'modal'
      end
    end

    private

    def any_goal?
      @progress[:weekly] || @progress[:monthly] || @progress[:annual]
    end

    def header_section
      div(class: 'mb-6 flex items-center justify-between') do
        div do
          h1(class: 'text-2xl lg:text-3xl font-bold text-slate-900 tracking-tight') { t('goals.index.title') }
          p(class: 'text-sm text-slate-500 mt-0.5') { subtitle_text }
        end
        link_to(
          helpers.new_goal_path,
          data:  { turbo_frame: 'modal' },
          class: 'inline-flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg px-4 py-2 text-sm font-semibold'
        ) do
          render PhlexIcons::Lucide::Plus.new(class: 'w-4 h-4')
          plain t('goals.index.empty.cta')
        end
      end
    end

    def subtitle_text
      year = @filters[:year] || Date.current.year
      month = @filters[:month] || Date.current.month
      month_name = I18n.l(Date.new(year, month, 1), format: '%B').capitalize
      t('goals.index.subtitle', month_name: month_name, year: year)
    end

    def hero_section
      return unless @progress[:monthly]

      div(class: 'mb-6 hidden lg:block') do
        render Goals::MonthlyGoalCardComponent.new(progress: @progress[:monthly], variant: :wide)
      end
    end

    def columns_section
      div(class: 'grid grid-cols-12 gap-4 mb-6') do
        div(class: 'col-span-12 lg:hidden') do
          render Goals::MonthlyGoalCardComponent.new(progress: @progress[:monthly]) if @progress[:monthly]
        end
        weekly_column
        annual_column
        achievements_column
      end
    end

    def weekly_column
      return unless @progress[:weekly]

      weekly = @progress[:weekly]
      goal = weekly[:goal]

      div(class: 'col-span-12 lg:col-span-5 bg-white rounded-2xl border border-slate-200 shadow-sm p-5') do
        div(class: 'flex items-center justify-between mb-3') do
          div(class: 'flex items-center gap-2') do
            div(class: 'w-8 h-8 rounded-full bg-emerald-100 flex items-center justify-center text-emerald-600') do
              render PhlexIcons::Lucide::Calendar.new(class: 'w-4 h-4')
            end
            div do
              p(class: 'text-sm font-semibold text-slate-800') { t('goals.index.weekly.label') }
              p(class: 'text-xs text-slate-500 lg:hidden') { weekly_period_label(goal) }
              p(class: 'hidden lg:block text-xs text-slate-500') do
                plain "#{weekly_period_label(goal)} · #{t('goals.index.weekly.progress', value: format_currency(weekly[:current]), target: format_currency(weekly[:target]))}"
              end
            end
          end
          span(class: 'text-xs font-medium text-emerald-700 bg-emerald-50 px-2 py-1 rounded-full') do
            plain "#{weekly[:percent].to_f.round(1)}%"
          end
        end
        render Goals::WeeklyBarsComponent.new(days: weekly[:days], target: weekly[:target])
        div(class: 'flex items-center justify-between text-xs mt-2 lg:hidden') do
          span(class: 'text-slate-500') do
            plain t('goals.index.weekly.progress', value: format_currency(weekly[:current]), target: format_currency(weekly[:target]))
          end
          span(class: 'text-slate-700 font-medium') do
            plain t('goals.index.weekly.remaining', value: format_currency([weekly[:target] - weekly[:current], 0].max))
          end
        end
      end
    end

    def annual_column
      return unless @progress[:annual]

      div(class: 'col-span-12 lg:col-span-3') do
        render Goals::AnnualBarComponent.new(progress: @progress[:annual])
      end
    end

    def achievements_column
      div(class: 'col-span-12 lg:col-span-4 lg:bg-white lg:rounded-xl lg:border lg:border-slate-200 lg:p-5') do
        render Goals::AchievementsRowComponent.new(achievements: @progress[:achievements])
      end
    end

    def weekly_period_label(goal)
      start_day = I18n.l(goal.period_start, format: '%-d')
      end_label = I18n.l(goal.period_end, format: t('goals.index.weekly.date_format'))
      t('goals.index.weekly.period_range', start: start_day, end: end_label)
    end
  end
end
