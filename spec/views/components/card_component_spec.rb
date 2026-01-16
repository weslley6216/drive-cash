# frozen_string_literal: true

require "rails_helper"

RSpec.describe CardComponent, type: :component do
  describe "#view_template" do
    it "renders a card with default styling" do
      component = CardComponent.new

      html = component.call { "Card content" }

      expect(html).to include("<div")
      expect(html).to include("bg-white")
      expect(html).to include("rounded-lg")
      expect(html).to include("shadow-md")
      expect(html).to include("p-6")
      expect(html).to include("Card content")
    end

    it "renders without padding when padding: false" do
      component = CardComponent.new(padding: false)

      html = component.call { "Content" }

      expect(html).not_to include("p-6")
    end

    it "renders without shadow when shadow: false" do
      component = CardComponent.new(shadow: false)

      html = component.call { "Content" }

      expect(html).not_to include("shadow")
    end

    it "renders with small shadow" do
      component = CardComponent.new(shadow: :sm)

      html = component.call { "Content" }

      expect(html).to include("shadow-sm")
    end

    it "renders with large shadow" do
      component = CardComponent.new(shadow: :lg)

      html = component.call { "Content" }

      expect(html).to include("shadow-lg")
    end

    it "renders with extra large shadow" do
      component = CardComponent.new(shadow: :xl)

      html = component.call { "Content" }

      expect(html).to include("shadow-xl")
    end

    it "merges custom classes" do
      component = CardComponent.new(class: "max-w-md")

      html = component.call { "Content" }

      expect(html).to include("max-w-md")
      expect(html).to include("bg-white")
    end

    it "passes custom attributes" do
      component = CardComponent.new(id: "my-card", data: { controller: "card" })

      html = component.call { "Content" }

      expect(html).to include('id="my-card"')
      expect(html).to include('data-controller="card"')
    end
  end
end
