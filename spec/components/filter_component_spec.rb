require 'rails_helper'

RSpec.describe FilterComponent, type: :component do
  let(:available_years) { [2025, 2024, 2023] }

  describe '#view_template' do
    it 'renders the available year options' do
      component = FilterComponent.new(
        selected_year: 2024,
        selected_month: nil,
        available_years: available_years
      )

      html = view_context.render(component)

      expect(html).to include('<option value="2025">2025</option>')
      expect(html).to include('<option value="2023">2023</option>')
    end

    it 'selects the correct year' do
      component = FilterComponent.new(
        selected_year: 2024,
        selected_month: nil,
        available_years: available_years
      )

      html = view_context.render(component)

      expect(html).to include('value="2024" selected')
      expect(html).not_to include('value="2025" selected')
    end

    it "selects 'TODOS' when month is nil" do
      component = FilterComponent.new(
        selected_year: 2024,
        selected_month: nil,
        available_years: available_years
      )

      html = view_context.render(component)

      expect(html).to include('value="" selected>TODOS</option>')
    end

    it 'selects a specific month correctly' do
      component = FilterComponent.new(
        selected_year: 2024,
        selected_month: 5,
        available_years: available_years
      )

      html = view_context.render(component)

      expect(html).to include('value="5" selected>MAI</option>')
    end
  end

  context 'when compact: true' do
    let(:component) do
      FilterComponent.new(
        selected_year: 2025,
        selected_month: 5,
        available_years: available_years,
        compact: true
      )
    end
    let(:html) { view_context.render(component) }

    it 'does not render the full card wrapper' do
      expect(html).not_to include('bg-white rounded-lg shadow-md')
    end

    it 'renders inline selects without labels' do
      expect(html).to include('value="2025" selected')
      expect(html).to include('value="5" selected')
      expect(html).not_to include(I18n.t('filter_component.year'))
      expect(html).not_to include(I18n.t('filter_component.title'))
    end

    it 'uses pill styling classes' do
      expect(html).to include('rounded-lg')
      expect(html).to include('border-slate-200')
    end
  end
end
