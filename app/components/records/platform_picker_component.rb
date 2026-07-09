module Records
  class PlatformPickerComponent < ApplicationComponent
    include PlatformPalette

    def initialize(selected: nil)
      @selected = selected.to_s
    end

    def view_template
      section do
        p(class: 'text-xs font-bold text-slate-500 uppercase tracking-wider mb-3') do
          t('records.new_view.platform_label')
        end
        div(class: 'grid grid-cols-4 gap-2') do
          PLATFORM_META.each_key { |platform| platform_button(platform) }
        end
      end
    end

    private

    def platform_button(platform)
      color = platform_color(platform)
      label_text = t("activerecord.attributes.earning.platforms.#{platform}")
      label(
        class: 'group relative rounded-2xl p-3 flex flex-col items-center gap-2 cursor-pointer transition has-[:checked]:ring-2 has-[:checked]:ring-blue-500 has-[:checked]:ring-offset-1',
        style: "background: #{color}15; border: 1px solid #{color}30"
      ) do
        input(type: 'radio', name: 'record[platform]', value: platform, checked: @selected == platform, class: 'sr-only')
        div(
          class: 'w-9 h-9 rounded-lg flex items-center justify-center text-xs font-bold',
          style: "background: #{color}; color: #{platform_fg(platform)}"
        ) { label_text[0..3] }
        span(class: 'text-[10px] font-medium text-slate-700 leading-tight text-center') { label_text }
        span(class: 'hidden group-has-[:checked]:flex absolute -top-1.5 -right-1.5 w-5 h-5 rounded-full bg-blue-500 items-center justify-center text-white') do
          render PhlexIcons::Lucide::Check.new(class: 'w-3 h-3 stroke-[3]')
        end
      end
    end
  end
end
