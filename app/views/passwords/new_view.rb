class Passwords::NewView < ApplicationView
  def view_template
    render LayoutComponent.new(title: t('.title')) do
      div(class: 'min-h-[80vh] flex items-center justify-center p-4') do
        div(class: 'w-full max-w-sm') do
          header_section
          form_section
        end
      end
    end
  end

  private

  def header_section
    div(class: 'text-center mb-8') do
      h1(class: 'text-2xl font-bold text-slate-800') { t('.title') }
      p(class: 'text-slate-500 text-sm mt-1') { t('.subtitle') }
    end
  end

  def form_section
    div(class: 'bg-white rounded-2xl border border-slate-200 shadow-sm p-6') do
      form_with(url: helpers.passwords_path, data: { turbo: false }) do |form|
        div(class: 'space-y-4') do
          label(class: 'block text-sm font-medium text-slate-700 mb-1') { t('.email') }
          raw form.email_field(:email_address, required: true, class: 'w-full border border-slate-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500').to_s
          raw form.submit(t('.submit'), class: 'w-full bg-blue-600 text-white font-semibold py-2.5 rounded-lg hover:bg-blue-700 transition-colors cursor-pointer').to_s
        end
      end
    end
  end
end
