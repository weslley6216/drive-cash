require 'rails_helper'

RSpec.describe Vehicles::EmptyVehicleComponent, type: :component do
  describe '#view_template' do
    it 'renders the empty title and body' do
      html = view_context.render(described_class.new)

      expect(html).to include(I18n.t('vehicle.empty.title'))
      expect(html).to include(I18n.t('vehicle.empty.body'))
    end

    it 'renders the registration call to action' do
      html = view_context.render(described_class.new)

      expect(html).to include(I18n.t('vehicle.empty.cta'))
      expect(html).to include('#vehicle-registration')
    end

    it 'wraps the state in the shared card style' do
      html = view_context.render(described_class.new)

      expect(html).to include('bg-white rounded-xl shadow-sm border border-slate-100')
    end
  end
end
