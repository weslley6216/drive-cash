require 'rails_helper'

RSpec.describe History::Slice do
  describe 'sanitization' do
    it 'drops unknown types, categories and platforms' do
      slice = described_class.new(types: %w[bogus], categories: %w[nope], platforms: %w[nope])

      expect(slice.types).to eq([])
      expect(slice.categories).to eq([])
      expect(slice.platforms).to eq([])
    end

    it 'keeps the known values once each' do
      slice = described_class.new(types: %w[earnings earnings], categories: %w[fuel fuel meals], platforms: %w[uber])

      expect(slice.categories).to eq(%w[fuel meals])
      expect(slice.platforms).to eq(%w[uber])
      expect(slice.types).to eq(%w[earnings expenses])
    end

    it 'implies the expense type from a category and the earning type from a platform' do
      expect(described_class.new(categories: %w[fuel]).types).to eq(%w[expenses])
      expect(described_class.new(platforms: %w[uber]).types).to eq(%w[earnings])
    end

    it 'implies the expense type from the unpaid switch' do
      slice = described_class.new(unpaid: '1')

      expect(slice).to be_unpaid
      expect(slice.types).to eq(%w[expenses])
    end

    it 'reads a blank unpaid flag as off' do
      expect(described_class.new(unpaid: '')).not_to be_unpaid
    end

    it 'keeps vendors only under marked categories, stripped, unique and without blanks' do
      slice = described_class.new(categories: %w[fuel],
                                  vendors:    { 'fuel' => [' Posto Orense ', '', 'Posto Orense'], 'meals' => ['Lanchonete'] })

      expect(slice.vendors).to eq('fuel' => ['Posto Orense'])
    end

    it 'keeps the no-vendor sentinel as a vendor' do
      slice = described_class.new(categories: %w[car_wash], vendors: { 'car_wash' => [described_class::NO_VENDOR] })

      expect(slice.vendors).to eq('car_wash' => [described_class::NO_VENDOR])
    end
  end

  describe '.from_params' do
    it 'builds the slice from the string keyed request params' do
      slice = described_class.from_params('types' => %w[expenses], 'unpaid' => '1', 'categories' => %w[fuel],
                                          'vendors' => { 'fuel' => ['Posto Orense'] })

      expect(slice.to_params).to eq(types: %w[expenses], unpaid: '1', categories: %w[fuel], vendors: { 'fuel' => ['Posto Orense'] })
    end

    it 'builds an empty slice from empty params' do
      expect(described_class.from_params({}).to_params).to eq({})
    end
  end

  describe 'presets' do
    it 'serializes each chip preset to its params' do
      expect(described_class.preset('all').to_params).to eq({})
      expect(described_class.preset('earnings').to_params).to eq(types: %w[earnings])
      expect(described_class.preset('expenses').to_params).to eq(types: %w[expenses])
      expect(described_class.preset('unpaid').to_params).to eq(types: %w[expenses], unpaid: '1')
    end

    it 'recognizes the active chip preset from the type level' do
      expect(described_class.new.active_preset).to eq('all')
      expect(described_class.new(types: %w[earnings expenses]).active_preset).to eq('all')
      expect(described_class.new(types: %w[earnings]).active_preset).to eq('earnings')
      expect(described_class.new(types: %w[expenses]).active_preset).to eq('expenses')
      expect(described_class.new(types: %w[expenses], unpaid: '1').active_preset).to eq('unpaid')
    end

    it 'has no active preset while a category, platform or vendor is marked' do
      expect(described_class.new(categories: %w[fuel]).active_preset).to be_nil
    end
  end

  describe '#filtering? and #pill_count' do
    it 'filters once a category, platform or vendor is marked' do
      expect(described_class.new(platforms: %w[uber])).to be_filtering
      expect(described_class.new(types: %w[expenses], unpaid: '1')).not_to be_filtering
    end

    it 'counts the marked categories, platforms and vendors but not the unpaid switch' do
      slice = described_class.new(categories: %w[fuel car_wash], platforms: %w[uber], unpaid: '1',
                                  vendors: { 'fuel' => ['Posto Orense', 'Shell'] })

      expect(slice.pill_count).to eq(5)
    end
  end

  describe 'type inclusion' do
    it 'includes both types when nothing is marked' do
      slice = described_class.new

      expect(slice).to be_include_earnings
      expect(slice).to be_include_expenses
    end

    it 'includes only the expenses of a category slice' do
      slice = described_class.new(categories: %w[fuel])

      expect(slice).not_to be_include_earnings
      expect(slice).to be_include_expenses
    end
  end

  describe '#single_series?' do
    it 'is a single series for one category, with or without vendors, or one platform' do
      expect(described_class.new(categories: %w[fuel], vendors: { 'fuel' => ['Posto Orense'] })).to be_single_series
      expect(described_class.new(platforms: %w[uber])).to be_single_series
    end

    it 'is not a single series for two categories, mixed types or a category plus a platform' do
      expect(described_class.new(categories: %w[fuel car_wash])).not_to be_single_series
      expect(described_class.new(types: %w[earnings], categories: %w[fuel])).not_to be_single_series
      expect(described_class.new(categories: %w[fuel], platforms: %w[uber])).not_to be_single_series
    end
  end

  describe 'removing a level' do
    let(:slice) do
      described_class.new(categories: %w[fuel car_wash], platforms: %w[uber nine_nine], unpaid: '1',
                          vendors: { 'fuel' => ['Posto Orense'] })
    end

    it 'removes a category together with its vendors' do
      expect(slice.without_category('fuel').to_params)
        .to eq(types: %w[earnings expenses], unpaid: '1', categories: %w[car_wash], platforms: %w[uber nine_nine])
    end

    it 'removes the vendors of a category and keeps the category' do
      expect(slice.without_vendors('fuel').categories).to eq(%w[fuel car_wash])
      expect(slice.without_vendors('fuel').vendors).to eq({})
    end

    it 'removes one platform' do
      expect(slice.without_platform('uber').platforms).to eq(%w[nine_nine])
    end

    it 'turns the unpaid switch off' do
      expect(slice.without_unpaid).not_to be_unpaid
      expect(slice.without_unpaid.categories).to eq(%w[fuel car_wash])
    end
  end
end
