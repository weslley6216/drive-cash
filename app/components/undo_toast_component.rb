class UndoToastComponent < ApplicationComponent
  include Phlex::Rails::Helpers::ButtonTo

  def initialize(payload:)
    @payload = payload
  end

  def view_template
    div(class: 'fixed left-4 right-4 bottom-24 z-50 lg:left-auto lg:right-6 lg:bottom-6 lg:w-96 rounded-xl bg-slate-900 text-white px-4 py-3 flex items-center gap-3 shadow-lg',
        data:  { controller: 'flash', flash_delay_value: 6000 }) do
      icon_circle
      p(class: 'text-[13px] leading-snug flex-1') { message }
      button_to(t('maintenances.mark_done.undo'), @payload['path'], method: :delete, params: { restore: @payload['restore'] },
                class: 'text-xs font-semibold text-emerald-300')
    end
  end

  private

  def icon_circle
    div(class: 'w-6 h-6 rounded-full bg-emerald-500 flex items-center justify-center flex-shrink-0') do
      render PhlexIcons::Lucide::Check.new(class: 'w-[14px] h-[14px]')
    end
  end

  def message
    t('maintenances.mark_done.toast',
      item:  t("vehicle.maintenances.catalog.#{@payload['category']}"),
      km:    helpers.number_with_delimiter(@payload['km'], delimiter: '.'),
      count: @payload['count'])
  end
end
