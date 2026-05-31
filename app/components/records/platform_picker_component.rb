module Records
  class PlatformPickerComponent < ApplicationComponent
    PLATFORMS = [
      { id: 'uber',          label: 'Uber',          color: '#000000', fg: '#fff' },
      { id: 'nine_nine',     label: '99',            color: '#fbbf24', fg: '#000' },
      { id: 'ifood',         label: 'iFood',         color: '#ef4444', fg: '#fff' },
      { id: 'rappi',         label: 'Rappi',         color: '#dc2626', fg: '#fff' },
      { id: 'shopee',        label: 'Shopee',        color: '#f97316', fg: '#fff' },
      { id: 'amazon',        label: 'Amazon',        color: '#1e293b', fg: '#fff' },
      { id: 'mercado_livre', label: 'Mercado Livre', color: '#fef08a', fg: '#000' },
      { id: 'other',         label: 'Outras',        color: '#cbd5e1', fg: '#0f172a' }
    ].freeze

    def initialize(selected: nil)
      @selected = selected.to_s
    end

    def view_template
      section do
        p(class: 'text-xs font-bold text-slate-500 uppercase tracking-wider mb-3') do
          t('records.new_view.platform_label')
        end
        div(class: 'grid grid-cols-4 gap-2') do
          PLATFORMS.each { |platform| platform_button(platform) }
        end
      end
    end

    private

    def platform_button(platform)
      is_selected = @selected == platform[:id]
      label(
        class: "relative rounded-2xl p-3 flex flex-col items-center gap-2 cursor-pointer transition #{is_selected ? 'ring-2 ring-blue-500 ring-offset-1' : ''}",
        style: "background: #{platform[:color]}15; border: 1px solid #{platform[:color]}30"
      ) do
        input(type: 'radio', name: 'record[platform]', value: platform[:id], checked: is_selected, class: 'sr-only')
        div(
          class: 'w-9 h-9 rounded-lg flex items-center justify-center text-xs font-bold',
          style: "background: #{platform[:color]}; color: #{platform[:fg]}"
        ) { platform[:label][0..3] }
        span(class: 'text-[10px] font-medium text-slate-700 leading-tight text-center') { platform[:label] }
        if is_selected
          span(class: 'absolute -top-1.5 -right-1.5 w-5 h-5 rounded-full bg-blue-500 flex items-center justify-center text-white') do
            render PhlexIcons::Lucide::Check.new(class: 'w-3 h-3 stroke-[3]')
          end
        end
      end
    end
  end
end
