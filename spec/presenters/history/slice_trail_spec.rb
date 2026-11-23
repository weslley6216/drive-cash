require 'rails_helper'

RSpec.describe History::SliceTrail do
  it 'lists nothing for a slice without marked levels' do
    expect(described_class.new(History::Slice.preset('unpaid')).pills).to eq([])
  end

  it 'puts the unpaid pill first, then platforms, then each category followed by its vendors' do
    slice = History::Slice.new(unpaid: '1', platforms: %w[uber], categories: %w[fuel car_wash],
                               vendors: { 'fuel' => ['Posto Orense'] })

    pills = described_class.new(slice).pills

    expect(pills.map(&:label)).to eq(['Não pagas', 'Uber', 'Combustível', 'Posto Orense', 'Lavagem'])
    expect(pills.map(&:level)).to eq(%w[types platforms categories vendors categories])
    expect(pills.map(&:nested)).to eq([false, false, false, true, false])
  end

  it 'removes the category with its vendors from the category pill and only the vendors from the vendor pill' do
    slice = History::Slice.new(categories: %w[fuel], vendors: { 'fuel' => ['Posto Orense'] })

    category_pill, vendor_pill = described_class.new(slice).pills

    expect(category_pill.remove_params).to eq(types: %w[expenses])
    expect(vendor_pill.remove_params).to eq(types: %w[expenses], categories: %w[fuel])
  end

  it 'removes the unpaid switch and one platform from their pills' do
    slice = History::Slice.new(unpaid: '1', platforms: %w[uber], categories: %w[fuel])

    unpaid_pill, platform_pill = described_class.new(slice).pills

    expect(unpaid_pill.remove_params).to eq(types: %w[earnings expenses], categories: %w[fuel], platforms: %w[uber])
    expect(platform_pill.remove_params).to eq(types: %w[earnings expenses], unpaid: '1', categories: %w[fuel])
  end

  it 'merges two or more stations of the fuel category into one pill' do
    slice = History::Slice.new(categories: %w[fuel], vendors: { 'fuel' => ['Posto Orense', 'Shell'] })

    expect(described_class.new(slice).pills.last.label).to eq('2 postos')
  end

  it 'merges two or more vendors of another category into one pill' do
    slice = History::Slice.new(categories: %w[car_wash],
                               vendors:    { 'car_wash' => ['Lava-rápido Central', History::Slice::NO_VENDOR] })

    expect(described_class.new(slice).pills.last.label).to eq('2 estabelecimentos')
  end

  it 'labels the no-vendor sentinel' do
    slice = History::Slice.new(categories: %w[car_wash], vendors: { 'car_wash' => [History::Slice::NO_VENDOR] })

    expect(described_class.new(slice).pills.last.label).to eq('Sem estabelecimento')
  end

  describe '#sentence' do
    it 'describes the platforms and the categories with their vendors' do
      slice = History::Slice.new(platforms: %w[uber], categories: %w[fuel car_wash], vendors: { 'fuel' => ['Posto Orense'] })

      expect(described_class.new(slice).sentence).to eq('Uber, Combustível (Posto Orense) e Lavagem')
    end

    it 'counts the vendors when there are two or more' do
      slice = History::Slice.new(categories: %w[fuel], vendors: { 'fuel' => ['Posto Orense', 'Shell'] })

      expect(described_class.new(slice).sentence).to eq('Combustível (2 postos)')
    end
  end
end
