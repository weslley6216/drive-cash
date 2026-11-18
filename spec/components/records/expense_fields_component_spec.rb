require 'rails_helper'

RSpec.describe Records::ExpenseFieldsComponent, type: :component do
  let(:expense) { create(:expense, category: 'maintenance', vendor: 'Oficina Azul', description: 'Revisão', paid: false) }

  it 'checks the expense category and fills the vendor and the description' do
    html = view_context.render(described_class.new(expense: expense))

    expect(html).to include('value="maintenance" checked')
    expect(html).to include('value="Oficina Azul"')
    expect(html).to include('Revisão')
  end

  it 'leaves the paid toggle off for a saved unpaid expense' do
    html = view_context.render(described_class.new(expense: expense))

    expect(html).to include('name="record[paid]" value="1" class="peer sr-only"')
  end

  it 'turns the paid toggle on for a new expense' do
    html = view_context.render(described_class.new(expense: Expense.new))

    expect(html).to include('name="record[paid]" value="1" checked')
  end
end
