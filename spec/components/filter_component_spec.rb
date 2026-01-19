# spec/components/filter_component_spec.rb
# frozen_string_literal: true

require "rails_helper"

RSpec.describe FilterComponent, type: :component do
  describe "#view_template" do
    let(:available_years) { [2025, 2024, 2023] }

    it "renders the available years options" do
      component = FilterComponent.new(
        selected_year: 2024,
        selected_month: nil,
        available_years: available_years
      )

      # MUDANÇA PRINCIPAL: Usamos view_context.render em vez de component.call
      html = view_context.render(component)

      expect(html).to include('<option value="2025">2025</option>')
      expect(html).to include('<option value="2023">2023</option>')
    end

    it "selects the correct year handling Integer/String mismatch" do
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

    it "selects a specific month correctly" do
      component = FilterComponent.new(
        selected_year: 2024,
        selected_month: 5, # Maio
        available_years: available_years
      )

      html = view_context.render(component)

      # Agora o teste espera "MAIO" ou "MAI" dependendo do seu I18n.
      # Como usamos .upcase no componente, ele deve bater com o abbr_month_names do pt-BR.yml
      expect(html).to include('value="5" selected>MAI</option>')
    end
  end
end
