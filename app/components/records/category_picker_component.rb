module Records
  class CategoryPickerComponent < ApplicationComponent
    CATEGORIES = [
      { id: 'fuel',          label: 'Combustível',    icon: 'Fuel' },
      { id: 'maintenance',   label: 'Manutenção',     icon: 'Wrench' },
      { id: 'car_wash',      label: 'Lavagem',        icon: 'Sparkles' },
      { id: 'toll',          label: 'Pedágio',        icon: 'Route' },
      { id: 'parking',       label: 'Estacionamento', icon: 'CircleParking' },
      { id: 'documentation', label: 'Documentação',   icon: 'FileText' },
      { id: 'insurance',     label: 'Seguro',         icon: 'Shield' },
      { id: 'fine',          label: 'Multa',          icon: 'TriangleAlert' },
      { id: 'meals',         label: 'Refeições',      icon: 'Utensils' },
      { id: 'phone',         label: 'Telefone',       icon: 'Phone' },
      { id: 'other',         label: 'Outros',         icon: 'Package' }
    ].freeze

    def initialize(selected: nil)
      @selected = selected.to_s
    end

    def view_template
      section do
        p(class: 'text-xs font-bold text-slate-500 uppercase tracking-wider mb-3') do
          t('records.new_view.category_label')
        end
        div(class: 'grid grid-cols-4 sm:grid-cols-6 gap-2') do
          CATEGORIES.each { |category| category_button(category) }
        end
      end
    end

    private

    def category_button(category)
      is_selected = @selected == category[:id]
      label(class: 'group relative rounded-2xl p-3 flex flex-col items-center gap-2 border transition cursor-pointer bg-slate-50 border-slate-200 has-[:checked]:bg-red-50 has-[:checked]:border-red-300 has-[:checked]:ring-2 has-[:checked]:ring-red-500 has-[:checked]:ring-offset-1') do
        input(type: 'radio', name: 'record[category]', value: category[:id], checked: is_selected, class: 'sr-only')
        div(class: 'w-9 h-9 rounded-lg flex items-center justify-center bg-white text-slate-600 group-has-[:checked]:bg-red-500 group-has-[:checked]:text-white') do
          render PhlexIcons::Lucide.const_get(category[:icon]).new(class: 'w-4 h-4')
        end
        span(class: 'text-[10px] font-medium leading-tight text-center text-slate-600 group-has-[:checked]:text-red-900') { category[:label] }
      end
    end
  end
end
