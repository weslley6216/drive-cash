class Auth::OrDividerComponent < ApplicationComponent
  def view_template
    div(class: 'flex items-center gap-3 py-1') do
      div(class: 'flex-1 h-px bg-slate-200')
      span(class: 'text-xs text-slate-400') { t('.label') }
      div(class: 'flex-1 h-px bg-slate-200')
    end
  end
end
