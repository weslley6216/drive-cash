require 'rails_helper'

RSpec.describe Records::EntryTypeToggleComponent, type: :component do
  let(:html) { view_context.render(described_class.new(active: active)) }

  context 'when earning is active' do
    let(:active) { 'earning' }

    it 'highlights the earning button' do
      expect(html).to include('bg-white shadow-sm text-emerald-700')
      expect(html).to include(I18n.t('records.new_view.type_toggle.earning'))
    end

    it 'leaves expense unhighlighted' do
      expect(html).to match(/text-slate-500.*Despesa/m)
    end

    it 'renders hidden radio inputs targeted by Stimulus' do
      expect(html).to include('data-record-form-target="typeInput"')
      expect(html).to include('type="radio"')
      expect(html).to include('value="earning"')
      expect(html).to include('value="expense"')
    end
  end

  context 'when expense is active' do
    let(:active) { 'expense' }

    it 'highlights the expense button' do
      expect(html).to include('bg-white shadow-sm text-red-700')
    end
  end
end
