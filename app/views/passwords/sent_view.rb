class Passwords::SentView < ApplicationView
  def initialize(email_address:)
    @email_address = email_address
  end

  def view_template
    render LayoutComponent.new(title: t('.title'), auth: true) do
      render Auth::ShellComponent.new(brand: false, back: true) do |shell|
        shell.with_content { content_block }
      end
    end
  end

  private

  def content_block
    div(class: 'pt-2 lg:pt-0') do
      icon_ring
      h1(class: 'text-3xl font-bold text-slate-900 tracking-tight mt-6') { plain t('.heading') }
      body_text
      actions
    end
  end

  def icon_ring
    div(class: 'w-16 h-16 rounded-full bg-emerald-50 border border-emerald-100 flex items-center justify-center text-emerald-600') do
      render PhlexIcons::Lucide::Mail.new(class: 'w-7 h-7')
    end
  end

  def body_text
    p(class: 'text-sm text-slate-500 mt-2 leading-relaxed') do
      plain t('.body_prefix')
      span(class: 'font-semibold text-slate-700') { plain @email_address }
      plain t('.body_suffix')
    end
  end

  def actions
    div(class: 'space-y-3 mt-8') do
      render Auth::CtaComponent.new(label: t('.back'), icon: nil, href: helpers.new_session_path)
      resend_form
    end
  end

  def resend_form
    form_with(url: helpers.passwords_path, data: { turbo: false }) do
      input(type: 'hidden', name: 'email_address', value: @email_address)
      button(type: 'submit', class: 'w-full h-11 text-sm font-semibold text-blue-600 cursor-pointer') { plain t('.resend') }
    end
  end
end
