require 'rails_helper'

RSpec.describe Dashboard::BaseDetailService do
  subject(:service) { described_class.new }

  describe 'abstract interface' do
    it 'raises NotImplementedError for base_scope' do
      expect { service.send(:base_scope) }.to raise_error(NotImplementedError)
    end

    it 'raises NotImplementedError for empty_scope' do
      expect { service.send(:empty_scope) }.to raise_error(NotImplementedError)
    end

    it 'raises NotImplementedError for list_key' do
      expect { service.send(:list_key) }.to raise_error(NotImplementedError)
    end

    it 'raises NotImplementedError for by_month_key' do
      expect { service.send(:by_month_key) }.to raise_error(NotImplementedError)
    end
  end
end
