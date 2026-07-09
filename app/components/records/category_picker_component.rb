module Records
  class CategoryPickerComponent < ApplicationComponent
    include CategoryPalette

    def initialize(selected: nil)
      @selected = selected.to_s
    end

    def view_template
      section do
        p(class: 'text-xs font-bold text-slate-500 uppercase tracking-wider mb-3') do
          t('records.new_view.category_label')
        end
        div(class: 'grid grid-cols-4 sm:grid-cols-6 gap-2') do
          CATEGORY_META.each_key { |category| category_button(category) }
        end
      end
    end

    private

    def category_button(category)
      label(class: 'group relative rounded-2xl p-3 flex flex-col items-center gap-2 border transition cursor-pointer bg-slate-50 border-slate-200 has-[:checked]:bg-red-50 has-[:checked]:border-red-300 has-[:checked]:ring-2 has-[:checked]:ring-red-500 has-[:checked]:ring-offset-1') do
        input(type: 'radio', name: 'record[category]', value: category, checked: @selected == category, class: 'sr-only')
        div(class: 'w-9 h-9 rounded-lg flex items-center justify-center bg-white text-slate-600 group-has-[:checked]:bg-red-500 group-has-[:checked]:text-white') do
          render category_icon(category).new(class: 'w-4 h-4')
        end
        span(class: 'text-[10px] font-medium leading-tight text-center text-slate-600 group-has-[:checked]:text-red-900') do
          t("activerecord.attributes.expense.categories.#{category}")
        end
      end
    end
  end
end
