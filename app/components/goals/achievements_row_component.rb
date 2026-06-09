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
          div(class: 'grid grid-cols-3 gap-2 lg:grid-cols-1 lg:gap-0 lg:space-y-2') do
            @achievements.each { |achievement| render_item(achievement) }
          end
        end
      end
    end

    private

    def render_item(achievement)
      color = achievement[:color]
      div(class: 'bg-white rounded-xl border border-slate-100 p-3 text-center lg:bg-transparent lg:border-0 lg:rounded-none lg:p-0 lg:flex lg:items-center lg:gap-3 lg:text-left') do
        div(class: 'w-10 h-10 rounded-full mx-auto flex items-center justify-center mb-2 lg:mb-0 lg:w-9 lg:h-9 lg:mx-0 lg:flex-shrink-0',
            style: "background-color: #{color}20; color: #{color}") do
          icon_cls = icon_class_for(achievement[:icon])
          render icon_cls.new(class: 'w-5 h-5') if icon_cls
        end
        span(class: 'text-[11px] font-medium text-slate-700 leading-tight lg:text-sm') { achievement[:label] }
      end
    end

    def icon_class_for(name)
      "PhlexIcons::Lucide::#{name.split('-').map(&:capitalize).join}".constantize
    rescue NameError
      PhlexIcons::Lucide::Star
    end
  end
end
