class Auth::BackToLoginComponent < ApplicationComponent
  def view_template
    link_to(
      helpers.new_session_path,
      class: 'flex items-center gap-1.5 text-sm font-semibold text-slate-500 h-11 -ml-1 lg:h-auto lg:ml-0 lg:hover:text-slate-700'
    ) do
      render PhlexIcons::Lucide::ArrowLeft.new(class: 'w-[18px] h-[18px]')
      plain t('.label')
    end
  end
end
