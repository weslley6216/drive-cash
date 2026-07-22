# Referência — Models ActiveRecord

Detalhamento do padrão. Para a visão rápida, veja `SKILL.md`. Para código canônico, leia os
exemplares reais listados no `SKILL.md`.

---

## As três formas de enum

### 1. Enum inteiro (valores explícitos)

O padrão dominante. Valores numéricos **explícitos** (nunca posicional implícito, para não quebrar ao
reordenar), `prefix: true` para gerar predicados namespaced (`category_fuel?`).

```ruby
enum :category, {
  car_wash:      0,
  documentation: 1,
  fuel:          3,
  other:         10
}, prefix: true
```

Adicione `validate: true` (ou `validate: { allow_nil: true }`) quando o valor precisa ser validado
como parte do domínio — é o caso de `Export` (`period_kind`/`format`/`status`) e de `User.plan_billing`.

### 2. Enum string (a partir de uma constante)

Quando o valor persistido é a própria string do domínio, defina a constante e derive o enum dela.
É o formato de `Goal`:

```ruby
KINDS = %w[weekly monthly annual].freeze
METRICS = %w[profit earnings].freeze

enum :kind, KINDS.zip(KINDS).to_h, prefix: true
enum :metric, METRICS.zip(METRICS).to_h, prefix: true
```

A constante fica disponível para specs e colaboradores (`Goal::KINDS`), e o enum e a constante
nunca divergem.

### 3. Conjunto que cresce — string + inclusion contra registry (NÃO enum)

Quando o conjunto de valores **cresce por extensão** (OCP) e é resolvido por um registry no service,
não use enum: use uma coluna string validada por `inclusion` contra o registry. É o caso de
`Notification.kind`:

```ruby
validates :kind, presence: true, inclusion: { in: Notifications::Registry::KINDS }
```

Assim, adicionar um `kind` novo = uma entrada no registry (service), sem tocar no model.

### Rótulo i18n do enum

`ApplicationRecord` fornece `human_enum_name`, que resolve o rótulo por convenção:

```ruby
Expense.human_enum_name(:category, :fuel) # => "Combustível"
# activerecord.attributes.expense.categories.fuel
```

O model devolve a **chave** do enum (dado cru); a tradução acontece via este helper na camada de
apresentação. Nunca hardcodar rótulo visível no model.

---

## Os concerns da camada de model

Cross-cutting **não é uma camada** — mora em `app/models/concerns/`. Três concerns hoje:

- **`MonetaryAmount`** — expõe a macro `monetize(*attributes)`, que sobrescreve o setter de cada
  atributo para converter string BR (`"1.234,56"` → `"1234.56"`) antes de persistir. Base de todo
  campo `decimal(10,2)`.
- **`FinancialEntry`** — o concern das entradas financeiras (`Expense`, `Earning`). Injeta:
  `belongs_to :user`, `monetize :amount`, validações de `date`/`amount`, o `class_attribute :credit`
  (Earning marca `self.credit = true`) e os **scopes financeiros compartilhados**
  (`chronological`, `for_year`, `for_month`, `in_period`). Inclui `MonetaryAmount`.
- **`VendorNormalization`** — `before_validation :normalize_vendor` (strip + colapsa espaços). Incluído
  por `Expense` e `Refueling`.

Regra: se dois ou mais models compartilham o mesmo comportamento transversal, ele vira concern — não
se copia validação/scope entre models.

---

## O limite de negócio é invariante do model AR

**A constante de limite (`MAX_*`, `MIN_*`) e a `validates` correspondente moram no model** — o model é
o dono do invariante. Um value object que precisa do limite **referencia** a constante do model:

```ruby
class Expense < ApplicationRecord
  MIN_INSTALLMENTS = 2
  MAX_INSTALLMENTS = 60

  validates :installment_count,
            numericality: { greater_than_or_equal_to: MIN_INSTALLMENTS, less_than_or_equal_to: MAX_INSTALLMENTS },
            allow_nil:    true
end
```

Por quê: se o limite vivesse só no value object, dava para criar um registro inválido direto pelo
model. A `validates` no model é a última linha de defesa. Fonte única, uma verdade só. (Veja o outro
lado dessa regra em **arch-value-object**.)

---

## A costura model ↔ value object

O model **persiste**; o value object **calcula/valida** sem banco. Quando a resolução de um campo é um
conceito de domínio com invariante, o model **delega** a um value object e grava o resultado. `Export`
delega a resolução do período a `Exports::PeriodRange`:

```ruby
before_validation :apply_period_range

def apply_period_range
  return if period_kind.blank?
  return unless self.class.period_kinds.key?(period_kind)

  range = Exports::PeriodRange.new(kind: period_kind, custom_start: period_start, custom_end: period_end)
  self.period_start = range.period_start
  self.period_end = range.period_end
end
```

O model não recalcula datas na mão; ele instancia o value object e persiste a saída. Cálculo de
domínio fica no VO, persistência no model.

---

## Método de domínio no model vs calculador no service

Consulta derivada do **próprio estado já carregado**, barata e de um passo, fica como método do model:
`Goal#ended?`, `Expense#installment?`, `Notification#unread?`, `Vehicle#updated_days_ago`,
`Maintenance#progress/done/target/km_until`. Todas leem os atributos do próprio registro (ou de uma
associação direta) e respondem.

Cálculo de domínio **pesado**, com múltiplas fontes ou orquestração, sai do model para um service /
calculador puro em `app/services/<domínio>/` (ex.: `Vehicles::MaintenanceService`,
`Dashboard::EarningsCalculator`). O sinal: se o método precisaria de outra tabela, de agregação
cara, ou de formatação, não é método de model.

---

## Associações, scopes e callbacks

- **Associações** sempre com `dependent:` explícito: `has_many :maintenances, dependent: :destroy`,
  `has_one :refueling, dependent: :nullify`, `belongs_to :expense, optional: true`. O `belongs_to :user`
  das entradas financeiras vem do concern `FinancialEntry`.
- **Scopes** são lambdas chainable e **compõem** outros scopes:
  ```ruby
  scope :paid_only, -> { where(paid: true) }
  scope :paid_in_period, lambda { |year, month = nil|
    relation = paid_only.for_year(year)
    month ? relation.for_month(month) : relation
  }
  ```
- **Validação cross-field** é um `validate :metodo` privado que adiciona erro com **chave i18n**
  (símbolo), nunca string literal: `errors.add(:period_end, :after_start)`.
- **Callbacks** para normalização/defaults: `before_validation` (resolver período, normalizar vendor),
  `before_save` (derivar `price_per_liter`, carimbar `odometer_updated_at`), `after_initialize
  :apply_defaults, if: :new_record?`.

---

## Padrão de spec (com FactoryBot)

O model tem spec em `spec/models/<singular>_spec.rb`, `type: :model`. Diferente do value object, o
model **usa FactoryBot** (`build`/`create`) — nunca `.new` cru — e cada model tem sua factory em
`spec/factories/<plural>.rb` com o mínimo de atributos válidos.

Cobrir, organizando por `describe` de aspecto:

- **Validações**: shoulda-matchers para as simples (`is_expected.to validate_presence_of(:amount)`);
  para cross-field/limites, `build(:model, campo: valor)` → `model.valid?` → `expect(model.errors[:campo]).to be_present`.
  Fronteiras de limite referenciam a constante (`Expense::MAX_INSTALLMENTS`), não número mágico, com
  o par válido/inválido nos dois lados.
- **Enums**: `define_enum_for(:category).with_values(...).with_prefix.backed_by_column_of_type(:integer)`;
  para enum string, `expect(described_class.kinds).to eq('weekly' => 'weekly', ...)`.
- **Scopes**: cria registros dentro e fora do escopo e afirma `include`/`not_to include` (o par
  positivo+negativo é o discriminante — não é teste só-negativo proibido).
- **Métodos de domínio e class methods**: `#ended?`, `.new_form_defaults` etc., com `travel_to` quando
  dependem de data.
- **Associação obrigatória**: `build(:model, user: nil)` → `errors[:user]` presente.

```ruby
RSpec.describe Goal, type: :model do
  describe 'validations' do
    subject { build(:goal) }

    it { is_expected.to validate_presence_of(:target_amount) }

    it 'rejects period_end before period_start' do
      goal = build(:goal, period_start: Date.new(2026, 6, 10), period_end: Date.new(2026, 6, 1))

      goal.valid?

      expect(goal.errors[:period_end]).to be_present
    end
  end
end
```

Regras gerais de RSpec (sem `let!`, AAA com linha vazia, sem comentários, sem
`allow_any_instance_of`, teste só-negativo exige par positivo, cobertura 100%) estão em **arch-spec**.

---

## Anti-padrões

- Reusar o nome singular do model como **namespace** (`module Expense`) — dá `TypeError`. Namespace de
  colaborador é plural (`Expenses::`).
- Enum inteiro com valores **posicionais implícitos** (`enum :status, %i[a b c]`) — reordenar corrompe
  dados; sempre valores explícitos.
- Definir o limite `MAX_*`/`MIN_*` **só** no value object ou no service — ele é invariante do model.
- Copiar validação/scope entre models em vez de extrair um **concern**.
- `has_many`/`has_one` **sem** `dependent:` — deixa órfãos.
- Cálculo de domínio pesado ou formatação (`number_to_currency`, cor, i18n visível) **dentro** do model
  — cálculo vai para service, apresentação para component Phlex.
- `errors.add` com **string literal** em vez de chave i18n (símbolo).
- Escrever comentário `#` no arquivo `.rb` — o nome de método/variável explica.
- Spec de model com `.new` cru em vez de FactoryBot; ou entregar o model **sem** atualizar factory e spec.

---

## Checklist de revisão

**Model**

- [ ] `class <Singular> < ApplicationRecord`, arquivo `app/models/<singular>.rb`, top-level.
- [ ] Namespace de colaborador é **plural**; nunca `module <Singular>`.
- [ ] Enum inteiro com valores **explícitos** + `prefix`; `validate` quando o domínio exige.
- [ ] Enum string derivado de constante (`KINDS.zip(KINDS).to_h`); conjunto que cresce usa `inclusion` contra registry.
- [ ] Limites `MAX_*`/`MIN_*` como constante do model + `validates` correspondente (dono do invariante).
- [ ] Cross-cutting via **concern** (`FinancialEntry`/`MonetaryAmount`/`VendorNormalization`), não copiado.
- [ ] Monetário: coluna `decimal(10,2)` + `monetize`.
- [ ] Associações com `dependent:` explícito.
- [ ] Scopes chainable; validação cross-field com `errors.add(:campo, :chave_i18n)`.
- [ ] Método de domínio deriva do próprio estado; cálculo pesado extraído para service.
- [ ] Zero apresentação (moeda/cor/i18n visível) e zero orquestração multi-model no arquivo.

**Spec**

- [ ] Em `spec/models/<singular>_spec.rb`, `type: :model`, com **FactoryBot** + factory em `spec/factories/<plural>.rb`.
- [ ] Validações (shoulda-matchers + erros por campo), enums, scopes (par positivo+negativo), métodos e associação obrigatória cobertos.
- [ ] Fronteiras de limite referenciam a constante do model, ambos os lados.
- [ ] Segue **arch-spec** (sem `let!`, AAA com linha vazia, sem comentários, cobertura 100%).
