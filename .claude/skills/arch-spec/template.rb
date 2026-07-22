require 'rails_helper'

RSpec.describe ThingName, type: :model do
  describe '#predicate?' do
    it 'is true when the condition holds' do
      thing = build(:thing, flag: true)

      expect(thing.predicate?).to be(true)
    end

    it 'is false when the condition does not hold' do
      thing = build(:thing, flag: false)

      expect(thing.predicate?).to be(false)
    end
  end
end
