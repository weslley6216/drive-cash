class UndoToastComponent < ApplicationComponent
  include Phlex::Rails::Helpers::ButtonTo

  def initialize(payload:)
    @payload = payload
  end

  def view_template
    render ToastShellComponent.new do
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
