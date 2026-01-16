# frozen_string_literal: true

require "rails_helper"

RSpec.describe ButtonComponent, type: :component do
  describe "#view_template" do
    it "renders a button with primary variant by default" do
      component = ButtonComponent.new

      html = component.call { "Click me" }

      expect(html).to include("<button")
      expect(html).to include("bg-blue-600")
      expect(html).to include("Click me")
    end

    it "renders secondary variant" do
      component = ButtonComponent.new(variant: :secondary)

      html = component.call { "Secondary" }

      expect(html).to include("bg-gray-200")
      expect(html).to include("Secondary")
    end

    it "renders danger variant" do
      component = ButtonComponent.new(variant: :danger)

      html = component.call { "Delete" }

      expect(html).to include("bg-red-600")
      expect(html).to include("Delete")
    end

    it "renders success variant" do
      component = ButtonComponent.new(variant: :success)

      html = component.call { "Save" }

      expect(html).to include("bg-green-600")
      expect(html).to include("Save")
    end

    it "renders small size" do
      component = ButtonComponent.new(size: :small)

      html = component.call { "Small" }

      expect(html).to include("px-3 py-1.5")
      expect(html).to include("text-sm")
    end

    it "renders medium size by default" do
      component = ButtonComponent.new

      html = component.call { "Medium" }

      expect(html).to include("px-4 py-2")
      expect(html).to include("text-base")
    end

    it "renders large size" do
      component = ButtonComponent.new(size: :large)

      html = component.call { "Large" }

      expect(html).to include("px-6 py-3")
      expect(html).to include("text-lg")
    end

    it "merges custom classes" do
      component = ButtonComponent.new(class: "custom-class")

      html = component.call { "Custom" }

      expect(html).to include("custom-class")
      expect(html).to include("bg-blue-600")
    end

    it "passes custom attributes" do
      component = ButtonComponent.new(type: "submit", disabled: true)

      html = component.call { "Submit" }

      expect(html).to include('type="submit"')
      expect(html).to include("disabled")
    end
  end
end
