
# Regras de Testes

## Princípios

1. **Cobertura 100% obrigatória** — SimpleCov bloqueia CI se cair abaixo. Toda linha nova precisa de spec.
2. **Sem mocks de banco** — testes batem em banco real (PostgreSQL). Mocks de banco causaram incidentes passados.
3. **Factories, não fixtures** — usar Factory Bot para criar dados de teste.
4. **Isolamento transacional** — `DatabaseCleaner` limpa entre exemplos. `transactional_fixtures = false`.

## Estrutura de Specs

```
spec/
├── factories/          # Factory Bot — expense.rb, earning.rb
├── models/             # validações, métodos, scopes
├── requests/           # testes HTTP (controllers via request spec)
├── services/           # service objects
│   ├── dashboard/
│   ├── ai/
│   ├── chat/
│   └── expenses/
├── components/         # componentes Phlex (rendering)
├── views/              # view helpers
├── lib/                # LLM client e adapters
└── rails_helper.rb     # configuração global
```

A estrutura de `spec/` espelha `app/`. Um arquivo em `app/services/expenses/creator.rb` tem spec em `spec/services/expenses/creator_spec.rb`.

## Factories

```ruby
# spec/factories/expenses.rb
FactoryBot.define do
  factory :expense do
    amount      { Faker::Commerce.price }
    date        { Faker::Date.backward(days: 30) }
    category    { :fuel }
    description { Faker::Lorem.sentence }
    paid        { true }
  end
end

# Uso nos testes
let(:expense) { create(:expense) }
let(:expense) { create(:expense, category: :maintenance, paid: false) }
let(:expenses) { create_list(:expense, 3, date: Date.today) }
```

## Padrões por Camada

### Models (`spec/models/`)

```ruby
RSpec.describe Expense, type: :model do
  # Validações com shoulda-matchers
  it { is_expected.to validate_presence_of(:amount) }
  it { is_expected.to validate_presence_of(:date) }
  it { is_expected.to define_enum_for(:category) }

  # Scopes
  describe '.by_month' do
    it 'filtra pelo mês informado' do
      expense = create(:expense, date: Date.new(2024, 3, 15))
      other   = create(:expense, date: Date.new(2024, 4, 1))

      expect(Expense.by_month(3, 2024)).to include(expense)
      expect(Expense.by_month(3, 2024)).not_to include(other)
    end
  end

  # Métodos de instância
  describe '#installment?' do
    it 'retorna true quando tem installment_series_id' do
      expense = build(:expense, installment_series_id: SecureRandom.uuid)
      expect(expense.installment?).to be true
    end
  end
end
```

### Services (`spec/services/`)

```ruby
RSpec.describe Expenses::Creator do
  describe '.call' do
    context 'com params válidos' do
      it 'cria a despesa e retorna sucesso' do
        params = { amount: '150,00', date: Date.today, category: 'fuel' }
        result = described_class.call(params)

        expect(result).to be_success
        expect(result.expense).to be_persisted
      end
    end

    context 'com params inválidos' do
      it 'retorna falha com erros' do
        result = described_class.call({})

        expect(result).not_to be_success
        expect(result.errors).not_to be_empty
      end
    end
  end
end
```

### Controllers / Request Specs (`spec/requests/`)

```ruby
RSpec.describe 'Expenses', type: :request do
  describe 'POST /expenses' do
    context 'com dados válidos' do
      it 'cria a despesa e retorna turbo_stream' do
        post expenses_path, params: { expense: { amount: '100', date: '2024-03-01', category: 'fuel' } },
                            headers: { 'Accept' => 'text/vnd.turbo-stream.html' }

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('turbo-stream')
      end
    end
  end
end
```

### Components (`spec/components/`)

```ruby
RSpec.describe StatCardComponent, type: :component do
  it 'renderiza o título e valor' do
    component = described_class.new(title: 'Total', value: 'R$ 1.500,00')
    rendered  = render_inline(component)

    expect(rendered).to have_text('Total')
    expect(rendered).to have_text('R$ 1.500,00')
  end
end
```

### LLM / Lib (`spec/lib/`)

Adapters LLM são testados com respostas mockadas (HTTP externo — aqui mock é aceitável).

```ruby
RSpec.describe Llm::Adapters::Groq do
  let(:adapter) { described_class.new(api_key: 'test-key') }

  describe '#chat' do
    it 'retorna a mensagem parseada' do
      stub_request(:post, /api.groq.com/).to_return(
        status: 200,
        body: { choices: [{ message: { content: 'resposta' } }] }.to_json
      )

      result = adapter.chat(messages: [{ role: 'user', content: 'olá' }])
      expect(result[:content]).to eq('resposta')
    end
  end
end
```

## Rodando Testes

```bash
rtk bundle exec rspec                                  # suite completa
rtk bundle exec rspec spec/models/expense_spec.rb      # arquivo específico
rtk bundle exec rspec spec/services/                   # diretório inteiro
rtk bundle exec rspec --format documentation           # output verboso
rtk bundle exec rspec --tag focus                      # só testes com :focus
```

## Configuração (rails_helper.rb)

```ruby
RSpec.configure do |config|
  config.use_transactional_fixtures = false  # DatabaseCleaner cuida disso
  config.include FactoryBot::Syntax::Methods
  config.include Shoulda::Matchers::ActiveRecord, type: :model
end
```

## Relacionado

- [[01 - Arquitetura]]
- [[04 - Regras de Services]]
- [[08 - CI-CD]]
