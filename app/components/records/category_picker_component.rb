module Records
  class CategoryPickerComponent < ApplicationComponent
    include CategoryPalette

    def initialize(selected: nil)
      @selected = selected.to_s
    end

    def view_template
      section do
        p(class: 'text-xs font-bold text-slate-500 uppercase tracking-wider mb-3 lg:font-semibold lg:text-slate-600 lg:tracking-wide lg:mb-2') do
          t('records.new_view.category_label')
        end
        div(class: 'grid grid-cols-4 lg:grid-cols-6 gap-2') do
          CATEGORY_META.each_key { |category| category_button(category) }
        end
      end
    end

    private

    def category_button(category)
      label(class: 'group relative rounded-2xl lg:rounded-xl p-3 flex flex-col items-center gap-2 lg:gap-1.5 border transition cursor-pointer bg-slate-50 border-slate-200 ' \
                   'lg:hover:bg-slate-100 has-[:checked]:bg-red-50 has-[:checked]:border-red-300 has-[:checked]:ring-2 has-[:checked]:ring-red-500 ' \
                   'has-[:checked]:ring-offset-1 lg:has-[:checked]:ring-offset-2') do
        input(type: 'radio', name: 'record[category]', value: category, checked: @selected == category, class: 'sr-only')
        div(class: 'w-9 h-9 lg:w-8 lg:h-8 rounded-lg flex items-center justify-center bg-white text-slate-600 group-has-[:checked]:bg-red-500 group-has-[:checked]:text-white') do
          render category_icon(category).new(class: 'w-4 h-4 lg:w-[15px] lg:h-[15px]')
        end
        span(class: 'text-[10px] font-medium leading-tight text-center text-slate-600 group-has-[:checked]:text-red-900') do
          t("activerecord.attributes.expense.categories.#{category}")
        end
      end
    end
  end
end
