
# Convenções

## Naming

| Tipo | Convenção | Exemplo |
|------|-----------|---------|
| Classes | PascalCase | `ExpensesController`, `InstallmentPlan` |
| Módulos | PascalCase | `Expenses::`, `Ai::`, `Dashboard::` |
| Métodos | snake_case | `calculate_total`, `parse_response` |
| Variáveis | snake_case | `monthly_earnings`, `trip_count` |
| Constantes | UPPER_SNAKE_CASE | `INSTALLMENT_PERIODS`, `MAX_MESSAGES` |
| Arquivos | snake_case | `installment_plan.rb`, `earnings_calculator.rb` |
| Tabelas DB | snake_case plural | `expenses`, `solid_cache_entries` |
| Colunas DB | snake_case | `installment_series_id`, `trips_count` |

## Organização de Arquivos

### Regra geral: arquivo espelha namespace

```
app/services/expenses/creator.rb         → Expenses::Creator
app/services/dashboard/stats_service.rb  → Dashboard::StatsService
app/components/stat_card_component.rb    → StatCardComponent
spec/services/expenses/creator_spec.rb   → spec de Expenses::Creator
```

### Services: sempre em subdiretório de domínio

```
app/services/
├── dashboard/   # nunca criar service na raiz de services/
├── ai/
├── chat/
└── expenses/
```

### Components: flat (sem subdiretório)

```
app/components/
├── application_component.rb
├── card_component.rb
├── button_component.rb
└── concerns/
    ├── button_styles.rb
    └── form_fields.rb
```

### Views: por domínio

```
app/views/
├── dashboard/
│   └── index_view.rb
├── expenses/
│   ├── new_view.rb
│   └── edit_view.rb
└── chat/
    └── index_view.rb
```

## Ruby Style (Rubocop Omakase)

Configurado via `.rubocop.yml` com herança de `rubocop-rails-omakase`.

Pontos principais:
- **Frozen string literals** não obrigatório (desativado)
- **Target**: Ruby 3.3
- **Excluídos**: `bin/`, `config/`, `db/`, `spec/`
- Comprimento de linha: padrão Omakase (120 chars)
- Aspas: simples por padrão (`'string'`)

Para verificar:

```bash
rtk bundle exec rubocop                     # todos os arquivos
rtk bundle exec rubocop app/services/       # diretório específico
rtk bundle exec rubocop --autocorrect       # correção automática
```

## Comentários

Evitar comentários que explicam "o quê" — o código deve ser auto-descritivo. Comentar apenas:
- Constraints não óbvios
- Workarounds para bugs específicos de gems
- Invariantes sutis que surpreenderiam um leitor

## Internacionalização (i18n)

- **Locale primário**: `pt-BR` (Português Brasileiro)
- **Fuso horário**: Brasília (`config.time_zone = "Brasilia"`)
- **Separador decimal**: vírgula (`1.234,56`)
- **Moeda**: R$ (Real)

### Estrutura de locales

```
config/locales/
├── pt-BR.yml          # strings gerais
├── chat.pt-BR.yml     # strings do chat
├── en.yml             # fallback inglês
└── {modelo}.pt-BR.yml # strings de modelo específico
```

### Uso obrigatório de t()

```ruby
# Em views/components:
t("expenses.categories.fuel")   # => "Combustível"
t("shared.save")                # => "Salvar"

# Em models (erros de validação):
validates :amount, presence: { message: :blank }
# Mensagem em: config/locales/pt-BR.yml > activerecord.errors.models.expense
```

### Enums e i18n

Nomes de enum são internacionalizados. Não exibir `.humanize` direto — usar translation:

```ruby
# config/locales/pt-BR.yml
activerecord:
  attributes:
    expense:
      categories:
        fuel: "Combustível"
        maintenance: "Manutenção"
```

## Monetário

- Sempre `decimal(10,2)` no banco
- Concern `MonetaryAmount` converte input antes de salvar
- Para exibição, concern `Formatting`:

```ruby
include Concerns::Formatting

format_currency(expense.amount)  # => "R$ 1.234,56"
```

## Relacionado

- [[01 - Arquitetura]]
- [[03 - Regras de Testes]]
- [[05 - Regras de Components]]
- [[08 - CI-CD]]
