# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationComponent, type: :component do
  describe "#class_names" do
    let(:component) { ApplicationComponent.new }

    it "joins multiple classes with spaces" do
      result = component.send(:class_names, "class1", "class2", "class3")

      expect(result).to eq("class1 class2 class3")
    end

    it "filters out nil values" do
      result = component.send(:class_names, "class1", nil, "class2", nil, "class3")

      expect(result).to eq("class1 class2 class3")
    end

    it "handles arrays" do
      result = component.send(:class_names, ["class1", "class2"], "class3")

      expect(result).to eq("class1 class2 class3")
    end

    it "handles nested arrays" do
      result = component.send(:class_names, ["class1", ["class2", "class3"]])

      expect(result).to eq("class1 class2 class3")
    end

    it "returns empty string for no arguments" do
      result = component.send(:class_names)

      expect(result).to eq("")
    end

    it "returns empty string for all nil arguments" do
      result = component.send(:class_names, nil, nil, nil)

      expect(result).to eq("")
    end
  end
end
