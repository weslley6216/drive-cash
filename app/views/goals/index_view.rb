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
          achievements_section
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
          data: { turbo_frame: 'modal' },
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
      div(class: 'grid grid-cols-1 lg:grid-cols-3 gap-4 mb-6') do
        div(class: 'lg:hidden') do
          render Goals::MonthlyGoalCardComponent.new(progress: @progress[:monthly]) if @progress[:monthly]
        end
        weekly_column
        annual_column
      end
    end

    def weekly_column
      return unless @progress[:weekly]

      div(class: 'bg-white rounded-2xl border border-slate-200 shadow-sm p-6 space-y-4') do
        p(class: 'text-sm font-medium text-slate-500') { t('goals.index.weekly.label') }
        render Goals::ProgressRingComponent.new(percent: @progress[:weekly][:percent], size: 120, color: '#10b981')
        render Goals::WeeklyBarsComponent.new(days: @progress[:weekly][:days], target: @progress[:weekly][:target])
      end
    end

    def annual_column
      return unless @progress[:annual]

      div(class: 'bg-white rounded-2xl border border-slate-200 shadow-sm p-6 space-y-4') do
        render Goals::ProgressRingComponent.new(percent: @progress[:annual][:percent], size: 120, color: '#8b5cf6')
        render Goals::AnnualBarComponent.new(progress: @progress[:annual])
      end
    end

    def achievements_section
      div(class: 'mt-6') do
        render Goals::AchievementsRowComponent.new(achievements: @progress[:achievements])
      end
    end
  end
end
