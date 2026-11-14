class Auth::GoogleButtonComponent < ApplicationComponent
  def view_template
    form(action: '/auth/google_oauth2', method: 'post', data: { turbo: 'false' }) do
      raw helpers.hidden_field_tag(:authenticity_token, helpers.form_authenticity_token)
      button(
        type:  'submit',
        class: 'w-full flex items-center justify-center gap-2.5 bg-white border border-slate-200 rounded-xl py-3 text-sm font-semibold text-slate-700 hover:bg-slate-50 cursor-pointer'
      ) do
        span(class: 'w-5 h-5 rounded-full bg-gradient-to-br from-blue-500 via-emerald-500 to-amber-500 flex items-center justify-center text-white text-[11px] font-bold') { plain 'G' }
        span { t('.label') }
      end
    end
  end
end
