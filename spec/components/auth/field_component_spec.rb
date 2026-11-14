require 'rails_helper'

RSpec.describe Auth::FieldComponent, type: :component do
  let(:form) { ActionView::Helpers::FormBuilder.new(:user, User.new, view_context, {}) }

  def render_field(**options)
    view_context.render(
      described_class.new(form: form, attribute: :email_address, label: 'E-mail',
                          icon: PhlexIcons::Lucide::Mail, type: :email, autocomplete: 'email', **options)
    )
  end

  it 'renders a labelled required input with the leading icon in the prototype style' do
    html = render_field

    expect(html).to include('<label class="text-xs font-semibold text-slate-600 mb-1.5 block" for="email_address">E-mail</label>')
    expect(html).to include('type="email"')
    expect(html).to include('id="email_address"')
    expect(html).to include('required')
    expect(html).to include(PhlexIcons::Lucide::Mail.new(class: 'w-[18px] h-[18px]').call)
    expect(html).to include('rounded-xl pl-11 pr-4 py-3')
    expect(html).to include('border-slate-200 focus:ring-blue-500')
  end

  it 'turns the border red and shows the message with an alert icon when an error is given' do
    html = render_field(error: 'já está em uso')

    expect(html).to include('border-red-300 ring-2 ring-red-100')
    expect(html).to include('text-xs font-medium text-red-600 mt-1.5 flex items-center gap-1.5')
    expect(html).to include('já está em uso')
  end
end
