module Goals
  class AchievementsRowComponent < ApplicationComponent
    def initialize(achievements:)
      @achievements = achievements
    end

    def view_template
      div(class: 'space-y-3') do
        h3(class: 'text-sm font-semibold text-slate-700') { t('goals.index.achievements.title') }
        if @achievements.empty?
          p(class: 'text-xs text-slate-400') { t('goals.index.achievements.empty') }
        else
          div(class: 'flex flex-wrap gap-3') do
            @achievements.each { |achievement| render_badge(achievement) }
          end
        end
      end
    end

    private

    def render_badge(achievement)
      div(class: 'flex items-center gap-2 px-3 py-2 rounded-full text-white text-xs font-medium',
          style: "background-color: #{achievement[:color]}") do
        span(class: 'inline-block w-2 h-2 rounded-full bg-white/80')
        span { achievement[:label] }
      end
    end
  end
end
