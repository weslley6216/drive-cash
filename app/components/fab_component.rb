class FabComponent < ApplicationComponent
  def initialize(filters: {})
    @filters = filters
  end

  def view_template
    div(
      class: 'fixed bottom-6 right-6 z-40 flex flex-col items-end gap-3',
      data: { controller: 'fab', action: 'click@window->fab#close' }
    ) do
      menu_options
      main_button
    end
  end

  private

  def menu_options
    div(
      data: { fab_target: 'menu' },
      class: 'hidden flex-col items-end gap-3 transition-all duration-200'
    ) do
      a(
        href: new_expense_path(context: @filters),
        data_turbo_frame: 'modal',
        class: 'flex items-center gap-2 bg-red-600 text-white px-4 py-2 rounded-full shadow-lg hover:bg-red-700 transition-all transform hover:scale-105'
      ) do
        span(class: 'text-sm font-medium whitespace-nowrap') { 'Despesa Avulsa' }
        render PhlexIcons::Lucide::Receipt.new(class: 'w-4 h-4')
      end

      a(
        href: new_trip_path(context: @filters),
        data_turbo_frame: 'modal',
        class: 'flex items-center gap-2 bg-emerald-600 text-white px-4 py-2 rounded-full shadow-lg hover:bg-emerald-700 transition-all transform hover:scale-105'
      ) do
        span(class: 'text-sm font-medium whitespace-nowrap') { 'Fechar o Dia' }
        render PhlexIcons::Lucide::Truck.new(class: 'w-4 h-4')
      end
    end
  end

  def main_button
    button(
      data: { action: 'fab#toggle', fab_target: 'button' },
      class: 'flex items-center justify-center w-14 h-14 rounded-full shadow-lg transition-all duration-200 bg-blue-600 text-white hover:bg-blue-700 hover:scale-105 active:scale-95 z-50'
    ) do
      render PhlexIcons::Lucide::Plus.new(class: 'w-6 h-6')
    end
  end
end
