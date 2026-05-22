
# Banco de Dados

## Schema

### `earnings` — Ganhos por plataforma

```sql
earnings
├── id               bigint PK
├── amount           decimal(10,2)   -- sempre com 2 casas decimais
├── date             date            -- data do ganho
├── platform         integer         -- enum (ver abaixo)
├── trips_count      integer         -- padrão 1
├── notes            text            -- observações livres
├── created_at       datetime
└── updated_at       datetime

Índices:
  [date], [platform], [date + platform]
```

### `expenses` — Despesas

```sql
expenses
├── id                    bigint PK
├── amount                decimal(10,2)
├── date                  date
├── category              integer         -- enum (ver abaixo)
├── vendor                string          -- opcional
├── description           text
├── paid                  boolean         -- padrão true
├── installment_series_id uuid            -- agrupa parcelas do mesmo gasto
├── installment_number    integer         -- 1-based (1a, 2a, 3a parcela...)
├── installment_count     integer         -- total de parcelas
├── created_at            datetime
└── updated_at            datetime

Índices:
  [date], [category], [date + category],
  [installment_series_id], [paid]
```

## Enums

### `Earning.platform`

```ruby
enum :platform, {
  amazon:         0,
  ifood:          1,
  mercado_livre:  2,
  nine_nine:      3,
  rappi:          4,
  shopee:         5,
  uber:           6,
  other:          7
}
```

### `Expense.category`

```ruby
enum :category, {
  fuel:          0,
  maintenance:   1,
  car_wash:      2,
  toll:          3,
  parking:       4,
  documentation: 5,
  insurance:     6,
  fine:          7,
  meals:         8,
  phone:         9,
  other:         10
}
```

### Períodos de parcelamento (sem enum no DB, usado nos services)

```ruby
INSTALLMENT_PERIODS = %i[weekly biweekly monthly annual]
```

## Padrões de Persistência

### Valores monetários

- Sempre `decimal(10,2)` no banco
- Input de usuário passa pelo concern `MonetaryAmount` antes de salvar
- Concern converte `"1.234,56"` → `1234.56` (strip, vírgula → ponto)
- **Nunca** salvar float no banco para valores financeiros

### Parcelamentos

- Cada parcela é um registro independente de `Expense`
- Agrupadas por `installment_series_id` (UUID gerado no `InstallmentPlan`)
- `installment_number` é 1-based: 1ª, 2ª, 3ª parcela
- Datas calculadas em `InstallmentPlan` com base no período (mensal, semanal etc.)

```ruby
# Para buscar todas as parcelas de um gasto:
Expense.where(installment_series_id: uuid)
```

### Invalidação de cache

Qualquer `save` ou `destroy` em `Expense` ou `Earning` dispara `CacheInvalidation`, que limpa `dashboard/available_years` do Solid Cache.

## Migrações

```bash
rtk bundle exec rails db:migrate           # aplica migrações pendentes
rtk bundle exec rails db:rollback          # reverte última migração
rtk bundle exec rails db:schema:load       # recria schema do zero
```

## Relacionado

- [[01 - Arquitetura]]
- [[04 - Regras de Services]]
