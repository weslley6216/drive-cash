module Goals
  class AchievementsRowComponent < ApplicationComponent
    BADGES = {
      streak:         { icon: PhlexIcons::Lucide::Flame, color: '#f97316' },
      goal_completed: { icon: PhlexIcons::Lucide::Star,  color: '#a855f7' },
      best_day:       { icon: PhlexIcons::Lucide::Zap,   color: '#3b82f6' }
    }.freeze
    DEFAULT_BADGE = { icon: PhlexIcons::Lucide::Star, color: '#64748b' }.freeze

    def initialize(achievements:)
      @achievements = achievements
    end

    def view_template
      div(class: 'space-y-3') do
        h3(class: 'text-sm font-semibold text-slate-700') { t('goals.index.achievements.title') }
        if @achievements.empty?
          p(class: 'text-xs text-slate-400') { t('goals.index.achievements.empty') }
        else
          div(class: 'grid grid-cols-3 gap-2 lg:grid-cols-1 lg:gap-0 lg:space-y-2') do
            @achievements.each { |achievement| render_item(achievement) }
          end
        end
      end
    end

    private

    def render_item(achievement)
      badge = BADGES.fetch(achievement[:type], DEFAULT_BADGE)
      color = badge[:color]
      div(class: 'bg-white rounded-xl border border-slate-100 p-3 text-center lg:bg-transparent lg:border-0 lg:rounded-none lg:p-0 lg:flex lg:items-center lg:gap-3 lg:text-left') do
        div(class: 'w-10 h-10 rounded-full mx-auto flex items-center justify-center mb-2 lg:mb-0 lg:w-9 lg:h-9 lg:mx-0 lg:flex-shrink-0',
            style: "background-color: #{color}20; color: #{color}") do
          render badge[:icon].new(class: 'w-5 h-5')
        end
        span(class: 'text-[11px] font-medium text-slate-700 leading-tight lg:text-sm') { achievement[:label] }
      end
    end
  end
end
