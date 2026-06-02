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

  context 'when popover: true' do
    let(:component) do
      FilterComponent.new(
        selected_year: 2025,
        selected_month: 3,
        available_years: available_years,
        popover: true
      )
    end
    let(:html) { view_context.render(component) }

    it 'renders a button as the popover trigger' do
      expect(html).to include('<button')
      expect(html).to include('click->filter-popover#toggle')
    end

    it 'renders the panel hidden by default' do
      expect(html).to match(/class="hidden[^"]*absolute/)
    end

    it 'uses filter-popover controller with window click-outside action' do
      expect(html).to include('data-controller="filter-popover"')
      expect(html).to include('click@window->filter-popover#closeOnOutsideClick')
    end

    it 'attaches the filter controller to the form so requestSubmit works' do
      expect(html).to match(/form[^>]*data-controller="filter"/)
    end

    it 'uses handleYearChange on year select to reset month before submitting' do
      expect(html).to include('handleYearChange')
    end

    it 'renders the funnel icon inside the button' do
      expect(html).to include('<button')
      expect(html).to include('svg')
    end

    it 'renders year and month selects inside the panel' do
      expect(html).to include('name="year"')
      expect(html).to include('name="month"')
    end

    it 'selects the correct year option' do
      expect(html).to include('value="2025" selected')
    end

    it 'selects the correct month option' do
      expect(html).to include('value="3" selected')
    end

    it 'renders labels for each field' do
      expect(html).to include(I18n.t('filter_component.year'))
      expect(html).to include(I18n.t('filter_component.month'))
    end

    it 'uses the provided action_path when given' do
      component = FilterComponent.new(
        selected_year: 2025,
        selected_month: nil,
        available_years: available_years,
        popover: true,
        action_path: '/analysis'
      )

      expect(view_context.render(component)).to include('action="/analysis"')
    end

    it 'does not render the full card wrapper' do
      expect(html).not_to include('bg-white rounded-lg shadow-md')
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
      expect(html).not_to include('shadow-md')
    end

    it 'renders inline selects without labels' do
      expect(html).to include('value="2025" selected')
      expect(html).to include('value="5" selected')
      expect(html).not_to include(I18n.t('filter_component.year'))
      expect(html).not_to include(I18n.t('filter_component.title'))
    end

    it 'uses pill styling classes' do
      expect(html).to include('border-slate-200')
    end

    it 'renders a form so filter#submit can call requestSubmit()' do
      expect(html).to include('<form')
      expect(html).to include('data-controller="filter"')
    end

    it 'uses handleYearChange on year select to reset month before submitting' do
      expect(html).to include('handleYearChange')
    end

    it 'uses the provided action_path when given' do
      component = FilterComponent.new(
        selected_year: 2025,
        selected_month: nil,
        available_years: available_years,
        compact: true,
        action_path: '/history'
      )

      expect(view_context.render(component)).to include('action="/history"')
    end
  end
end
