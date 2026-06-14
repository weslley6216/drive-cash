module Vehicles
  class EmptyVehicleComponent < ApplicationComponent
    def view_template
      div(class: 'bg-white rounded-2xl border border-slate-100 text-center py-8 px-5') do
        div(class: 'w-14 h-14 rounded-2xl bg-slate-100 text-slate-400 flex items-center justify-center mx-auto mb-3') do
          render PhlexIcons::Lucide::Truck.new(class: 'w-6 h-6')
        end
        p(class: 'text-base font-semibold text-slate-800') { t('vehicle.empty.title') }
        p(class: 'text-sm text-slate-500 mt-1 max-w-[260px] mx-auto leading-relaxed') { t('vehicle.empty.body') }
        a(href:  '#vehicle-registration',
          class: 'mt-4 inline-flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white rounded-xl px-4 py-2.5 text-sm font-semibold') do
          render PhlexIcons::Lucide::Plus.new(class: 'w-4 h-4')
          plain t('vehicle.empty.cta')
        end
      end
    end
  end
end
