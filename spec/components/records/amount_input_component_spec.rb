require 'rails_helper'

RSpec.describe Records::AmountInputComponent, type: :component do
  let(:html) { view_context.render(described_class.new(amount: 60.0, theme: :red, date: Date.new(2026, 5, 22))) }

  it 'renders the R$ prefix' do
    expect(html).to include('R$')
  end

  it 'renders the amount value as input' do
    expect(html).to include('name="record[amount]"')
    expect(html).to include('value="60.0"')
  end

  it 'renders the date label' do
    expect(html).to include(I18n.t('records.new_view.today'))
  end

  it 'applies red theme classes when theme=red' do
    expect(html).to include('text-red-700')
  end

  it 'applies emerald theme classes when theme=emerald' do
    html = view_context.render(described_class.new(amount: 0, theme: :emerald, date: Date.current))

    expect(html).to include('text-emerald-700')
  end

  it 'renders an editable date input (not hidden)' do
    expect(html).to include('type="date"')
    expect(html).to include('name="record[date]"')
    expect(html).to include('value="2026-05-22"')
  end

  it 'exposes Stimulus target for dynamic theme switching' do
    expect(html).to include('data-record-form-target="amountTheme"')
  end
end
