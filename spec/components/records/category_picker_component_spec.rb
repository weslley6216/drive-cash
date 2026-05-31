require 'rails_helper'

RSpec.describe Records::CategoryPickerComponent, type: :component do
  let(:html) { view_context.render(described_class.new(selected: 'fuel')) }

  it 'renders all 11 categories from Expense.categories' do
    expect(html.scan('type="radio"').size).to eq(Expense.categories.size)
    Expense.categories.each_key { |key| expect(html).to include("value=\"#{key}\"") }
  end

  it 'uses CSS has-[:checked] for red theme selection styling' do
    expect(html).to include('has-[:checked]:bg-red-50 has-[:checked]:border-red-300 has-[:checked]:ring-2 has-[:checked]:ring-red-500')
  end

  it 'renders the section label' do
    expect(html).to include(I18n.t('records.new_view.category_label'))
  end

  it 'uses a 4-column grid' do
    expect(html).to include('grid grid-cols-4')
  end
end
