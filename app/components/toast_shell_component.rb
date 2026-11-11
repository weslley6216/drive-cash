class ToastShellComponent < ApplicationComponent
  SHELL_CLASSES = 'fixed left-4 right-4 bottom-24 z-50 lg:left-auto lg:right-6 lg:bottom-6 lg:w-96 rounded-xl ' \
                  'bg-slate-900 text-white px-4 py-3 flex items-center gap-3 shadow-lg'

  def view_template(&)
    div(class: SHELL_CLASSES, data: { controller: 'flash', flash_delay_value: 6000 }, &)
  end
end
