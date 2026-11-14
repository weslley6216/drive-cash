module Goals
  class IndexView < ApplicationComponent
    include CardStyles
    include TopbarStyles

    def initialize(progress:, filters: {}, past_monthly: [], suggestion: nil)
      @progress = progress
      @filters = filters
      @past_monthly = past_monthly
      @suggestion = suggestion
    end

    def view_template
      render LayoutComponent.new(title: t('goals.index.title'), bottom_nav: :goals, sidebar_nav: :goals) do
        render ScreenComponent.new do |screen|
          screen.with_header { header_section }
          screen.with_content do
            if any_goal?
              hero_section
              columns_section
            else
              div(class: 'space-y-4') do
                div(class: CARD) do
                  render EmptyStateComponent.new(
                    icon:        PhlexIcons::Lucide::Target,
                    icon_color:  'text-blue-600',
                    ring:        'bg-blue-50 border-blue-100',
                    title:       t('empty_states.goals.title'),
                    description: t('empty_states.goals.description'),
                    cta_label:   t('empty_states.goals.cta'),
                    cta_path:    helpers.new_goal_path,
                    cta_icon:    PhlexIcons::Lucide::Target,
                    cta_data:    { turbo_frame: 'modal' }
                  )
                end
                render Goals::SuggestionCardComponent.new(amount: @suggestion) if @suggestion
              end
            end

            past_goals_section if @past_monthly.any?
          end
        end
        turbo_frame_tag 'modal'
      end
    end

    private

    def any_goal?
      @progress[:weekly] || @progress[:monthly] || @progress[:annual]
    end

    def header_section
      div(class: "#{PHONE_BAR} flex items-start justify-between gap-3 lg:items-center lg:gap-6 #{DESKTOP_BAR}") do
        div(class: 'min-w-0') do
          h1(class: 'text-2xl font-bold text-slate-800 leading-tight lg:leading-8 lg:text-slate-900 lg:tracking-tight') { t('goals.index.title') }
          p(class: 'text-sm text-slate-500 mt-0.5') { subtitle_text }
        end
        new_goal_button
        link_to(t('goals.index.new_goal'), helpers.new_goal_path,
                data:  { turbo_frame: 'modal' },
                class: 'hidden lg:inline text-sm font-medium text-blue-600 hover:underline')
      end
    end

    def new_goal_button
      link_to(helpers.new_goal_path,
              data:  { turbo_frame: 'modal', new_goal_button: true },
              aria:  { label: t('goals.index.new_goal_aria') },
              class: 'relative lg:hidden w-9 h-9 flex-shrink-0 rounded-full bg-white border border-slate-200 shadow-sm ' \
                          'flex items-center justify-center text-slate-600') do
        span(class: 'absolute -inset-[5px]')
        render PhlexIcons::Lucide::Plus.new(class: 'w-[18px] h-[18px]')
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
      div(class: 'grid grid-cols-12 gap-4 lg:gap-5 mb-6') do
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

      div(class: "col-span-12 lg:col-span-5 #{CARD} #{DESKTOP_FLAT} p-4 lg:p-5") do
        div(class: 'flex items-center justify-between mb-3') do
          div(class: 'flex items-center gap-2') do
            div(class: 'w-8 h-8 rounded-full bg-emerald-100 flex items-center justify-center text-emerald-600') do
              render PhlexIcons::Lucide::Calendar.new(class: 'w-4 h-4 lg:w-3.5 lg:h-3.5')
            end
            div do
              p(class: 'text-sm font-semibold text-slate-800') { t('goals.index.weekly.label') }
              p(class: 'text-xs text-slate-500 lg:hidden') { weekly_period_label(goal) }
              p(class: 'hidden lg:block text-xs text-slate-500') { weekly_desktop_summary(weekly) }
            end
          end
          div(class: 'flex items-center gap-2') do
            span(class: 'text-xs font-medium text-emerald-700 bg-emerald-50 px-2 py-1 lg:py-0.5 rounded-full') do
              plain "#{format_percentage(weekly[:percent].to_f)}%"
            end
            unless goal.ended?
              link_to(helpers.edit_goal_path(goal),
                      class: 'w-7 h-7 rounded-full bg-white border border-slate-200 flex items-center justify-center text-slate-500 hover:text-slate-700',
                      aria:  { label: t('goals.index.edit_aria') },
                      data:  { turbo_frame: 'modal' }) do
                render PhlexIcons::Lucide::Pencil.new(class: 'w-[14px] h-[14px]')
              end
            end
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

    def weekly_desktop_summary(weekly)
      goal = weekly[:goal]
      t('goals.index.weekly.desktop_summary',
        start:  goal.period_start.day,
        end:    I18n.l(goal.period_end, format: '%-d %B'),
        value:  format_currency_short(weekly[:current]),
        target: format_currency_short(weekly[:target]))
    end

    def weekly_period_label(goal)
      start_day = I18n.l(goal.period_start, format: '%-d')
      end_label = I18n.l(goal.period_end, format: t('goals.index.weekly.date_format'))
      t('goals.index.weekly.period_range', start: start_day, end: end_label)
    end

    def past_goals_section
      div(class: 'mt-8') do
        h2(class: 'text-lg font-semibold text-slate-800 mb-3') { t('goals.index.past_goals.title') }
        div(class: 'bg-white rounded-2xl border border-slate-100 overflow-hidden divide-y divide-slate-100') do
          @past_monthly.each { |row| past_goal_row(row) }
        end
      end
    end

    def past_goal_row(row)
      goal = row[:goal]
      div(class: 'flex items-center justify-between gap-4 px-4 py-3') do
        div(class: 'min-w-0') do
          p(class: 'text-sm font-semibold text-slate-800') { I18n.l(goal.period_start, format: '%B %Y').capitalize }
          p(class: 'text-xs text-slate-500') do
            plain "#{t('goals.index.past_goals.target_label')} #{format_currency(goal.target_amount)} · "
            plain "#{t('goals.index.past_goals.achieved_label')} #{format_currency(row[:current])}"
          end
        end
        result_chip(row)
      end
    end

    def result_chip(row)
      if row[:achieved]
        span(class: 'text-xs font-medium text-emerald-700 bg-emerald-50 px-2 py-1 rounded-full') do
          t('goals.index.past_goals.achieved_yes')
        end
      else
        span(class: 'text-xs font-medium text-amber-700 bg-amber-50 px-2 py-1 rounded-full') do
          t('goals.index.past_goals.achieved_no', percent: row[:percent].to_f.round(0))
        end
      end
    end
  end
end
