require 'rails_helper'

RSpec.describe Llm::BaseAdapter do
  subject(:adapter) { described_class.new }

  describe '#sanitize_function_leaks' do
    it 'strips XML-style function tags' do
      input = 'Hello <function name="test">body</function> world'

      result = adapter.send(:sanitize_function_leaks, input)

      expect(result).to eq('Hello  world')
    end

    it 'strips JSON-style field leaks' do
      input = "Done. {\"amount\": 50.0} ok"

      result = adapter.send(:sanitize_function_leaks, input)

      expect(result).to eq('Done.  ok')
    end

    it 'returns clean text unchanged' do
      input = 'Despesa registrada com sucesso.'

      result = adapter.send(:sanitize_function_leaks, input)

      expect(result).to eq(input)
    end
  end
end
