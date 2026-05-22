
# Regras de Services

## Princípios

1. **Toda lógica de negócio fica no service** — controllers são thin, só roteiam.
2. **Um service, uma responsabilidade** — se precisar de sub-etapas, crie services menores e componha.
3. **Interface `.call`** — todo service é invocado via `ServiceClass.call(args)`.
4. **Retorna result object** — nunca lança exceção para controle de fluxo. Retorna objeto com `success?`.
5. **Métodos privados** — lógica interna sempre em `private`.

## Estrutura de um Service

```ruby
module Expenses
  class Creator
    def self.call(params)
      new(params).call
    end

    def initialize(params)
      @params = params
    end

    def call
      expense = Expense.new(expense_attributes)

      if expense.save
        Result.new(success: true, expense: expense)
      else
        Result.new(success: false, errors: expense.errors.full_messages)
      end
    end

    private

    def expense_attributes
      @params.slice(:amount, :date, :category, :vendor, :description, :paid)
    end

    Result = Struct.new(:success, :expense, :errors, keyword_init: true) do
      def success? = success
    end
  end
end
```

## Result Objects

Todo service retorna um Struct com no mínimo:

```ruby
Result = Struct.new(:success, :errors, keyword_init: true) do
  def success? = success
end
```

Campos extras conforme domínio: `:expense`, `:earning`, `:messages`, `:preview` etc.

**Nunca use `raise` para controle de fluxo.** Exceções só para erros inesperados (falha HTTP, DB down).

## Domínios

### `Dashboard::` — Estatísticas

```
StatsService         # orquestra tudo: earnings, expenses, saldo
EarningsDetailService
ExpensesDetailService
EarningsCalculator   # soma, média, por plataforma
ExpensesCalculator   # soma, média, por categoria
ScopeMonthCounter    # concern compartilhado: conta por mês
```

`StatsService.call(month:, year:)` retorna hash completo para a view do dashboard.

### `Ai::` — Orquestração LLM

```
ParserService        # orquestra: monta prompt, chama LLM, interpreta tool call
ExpenseFromChat      # coerce JSON do LLM → atributos válidos de Expense
SummaryBuilder       # gera preview textual do que foi interpretado
Tools/               # declarações de function calling (schema JSON)
```

`Ai::ParserService.call(message:, history:)` retorna `{ type:, data:, summary: }`.

### `Chat::` — Persistência via Chat

```
RecordPersister      # dispatcher: expense ou earning?
ExpensePersister     # salva Expense a partir do resultado do LLM
EarningPersister     # salva Earning a partir do resultado do LLM
PersistedResult      # result object do chat (record, type, errors)
```

### `Expenses::` — Criação e Parcelamentos

```
Creator              # cria expense simples ou delega para InstallmentCreator
InstallmentCreator   # cria N expenses com mesmo installment_series_id
InstallmentPlan      # calcula datas e valores das parcelas
```

`InstallmentPlan.new(amount:, count:, period:, start_date:).build` retorna array de `{ date:, amount: }`.

## Composição de Services

```ruby
# Creator delega para InstallmentCreator quando é parcelado
def call
  if installment?
    Expenses::InstallmentCreator.call(@params)
  else
    create_single_expense
  end
end
```

## Scopes e Queries

Queries complexas ficam em scopes no model, services apenas compõem:

```ruby
# No model:
scope :by_month, ->(month, year) { where(date: Date.new(year, month).all_month) }
scope :by_category, ->(cat) { where(category: cat) }

# No service:
expenses = Expense.by_month(month, year).by_category(:fuel)
```

## Memoização

```ruby
def earnings_data
  @earnings_data ||= Earning.by_month(@month, @year).to_a
end
```

Use `||=` para evitar queries repetidas dentro do mesmo service call.

## Relacionado

- [[01 - Arquitetura]]
- [[03 - Regras de Testes]]
- [[06 - Integração LLM]]
