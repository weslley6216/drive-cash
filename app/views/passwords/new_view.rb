class Passwords::NewView < ApplicationView
  def view_template
    render LayoutComponent.new(title: t('.title'), auth: true) do
      div(class: 'min-h-screen flex items-center justify-center p-6 bg-gradient-to-br from-slate-50 to-slate-100') do
        div(class: 'w-full max-w-sm') do
          div(class: 'pb-8') { render BrandMarkComponent.new(size: :lg) }
          h1(class: 'text-3xl font-bold text-slate-900 tracking-tight') { t('.title') }
          p(class: 'text-sm text-slate-500 mt-2') { t('.subtitle') }
          form_block
        end
      end
    end
  end

  private

  def form_block
    form_with(url: helpers.passwords_path, data: { turbo: false }, class: 'space-y-4 mt-8') do |form|
      div do
        label(class: 'text-xs font-semibold text-slate-600 mb-1.5 block', for: 'email_address') { t('.email') }
        raw form.email_field(:email_address,
                             id:           'email_address',
                             required:     true,
                             autocomplete: 'email',
                             class:        'w-full bg-white border border-slate-200 rounded-xl px-4 py-3 text-sm text-slate-900 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500').to_s
      end
      raw form.submit(t('.submit'),
                      class: 'w-full bg-blue-600 hover:bg-blue-700 text-white rounded-xl py-3.5 text-sm font-semibold shadow-lg shadow-blue-600/25').to_s
    end
  end
end
