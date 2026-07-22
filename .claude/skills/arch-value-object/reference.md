# Referência — Value Objects

Detalhamento do padrão. Para a visão rápida, veja `SKILL.md`. Para código canônico, leia os
exemplares reais listados no `SKILL.md`.

---

## Os dois sub-formatos

### 1. Value object comportamental (classe)

Uma classe Ruby pura que recebe dados crus, coage, valida e responde consultas derivadas.
É o formato de `Expenses::InstallmentPlan` e `Exports::PeriodRange`.

Anatomia (extraída de `InstallmentPlan`):

```ruby
module Expenses
  class InstallmentPlan
    PERIOD_ADVANCE = {
      'weekly'   => ->(start, index) { start + index.weeks },
      'monthly'  => ->(start, index) { start >> index }
    }.freeze

    attr_reader :series_id, :count

    def initialize(total_amount:, start_date:, period:, repetitions:)
      @total_amount = BigDecimal(total_amount.to_s)
      @start_date = parse_date(start_date)
      @period = period.to_s
      @count = repetitions.to_i
    end

    def valid?
      @count.between?(Expense::MIN_INSTALLMENTS, Expense::MAX_INSTALLMENTS) &&
        Expense::INSTALLMENT_PERIODS.include?(@period) &&
        @total_amount.positive?
    end

    def amounts
      @amounts ||= calculate_amounts
    end

    private

    def calculate_amounts
      # cálculo puro, sem efeito colateral
    end
  end
end
```

Pontos que definem o padrão:

- **Coerção na fronteira**: o `initialize` recebe qualquer forma (string, número) e normaliza —
  `BigDecimal(total_amount.to_s)`, `period.to_s`, `repetitions.to_i`, `parse_date(...)`. Quem chama
  não precisa pré-formatar.
- **`valid?` como predicado**, não exceção. A construção nunca levanta; a validade é consultada.
- **Derivados memoizados** (`@amounts ||= ...`): calcula uma vez, imutável na prática.
- **Cálculo em métodos privados puros** — sem banco, sem I/O, sem apresentação.

### 2. Módulo-registry de dados

Quando não há comportamento, só **dado de referência estático**, use um `module` com uma constante
congelada. É o formato de `Plans::Catalog`:

```ruby
module Plans
  module Catalog
    PLANS = {
      free: { price_month: BigDecimal('0'),     features: %i[records caju_limit] },
      pro:  { price_month: BigDecimal('14.90'), features: %i[exports insights] }
    }.freeze
  end
end
```

Sem instância, sem `new`. É um registry puro (mapa de lookup) — o consumidor lê a constante.

---

## O limite de negócio mora no model AR

**Invariante de limite (`MAX_*`, `MIN_*`) é do model AR, não do value object.**

O value object **referencia** a constante do model:

```ruby
def valid?
  @count.between?(Expense::MIN_INSTALLMENTS, Expense::MAX_INSTALLMENTS)
end
```

Por quê: se o limite vivesse só no value object, dava para criar um registro inválido direto pelo
model (que tem sua própria `validates`). A constante e a `validates` correspondente moram no model
(`Expense::MAX_INSTALLMENTS` + `validates :installment_count, ...`); o value object aponta para ela.
Fonte única, uma verdade só.

---

## Registry para variação de domínio (OCP)

Conjunto que cresce (período de parcelamento, tipo de período de export) despacha por um **registry**
— um hash congelado resolvido por chave — nunca por `case/when` espalhado.

```ruby
PERIOD_ADVANCE.fetch(@period).call(start, index)
```

Adicionar uma variante = uma entrada no hash. Nada de `if período == 'weekly' … elsif …`.
Use `.fetch` (falha alto em chave desconhecida), não `[]`.

---

## Nada de apresentação no value object

O value object devolve **dado cru**: `BigDecimal`, `Date`, hash de atributos crus. **Nunca**:

- `number_to_currency`, `I18n.t`, símbolo de moeda
- cor, design token, classe Tailwind
- rótulo de UI

Isso é responsabilidade do **component Phlex** (que é Ruby — é o lar natural disso). Se você sentiu
vontade de formatar dentro do value object, o dado cru vai para o component e a formatação acontece lá.

---

## Padrão de spec (dedicado)

Cada value object tem um spec unitário dedicado espelhando o caminho. Como é objeto puro (não é model
de banco), **não** se usa factory: constrói-se com `.new(...)`. Segue o padrão de
`spec/models/expenses/installment_plan_spec.rb`.

Cobrir:

- **Invariante nas duas fronteiras**: válido em `MIN`/`MAX`, inválido em `MIN - 1`/`MAX + 1`, e
  inválido nas outras condições (`total_amount` não positivo, período desconhecido). Referencie as
  constantes do model no spec (`Expense::MAX_INSTALLMENTS`), não números mágicos.
- **Coerção**: passe o dado cru (ex.: `start_date` numérico) e verifique o valor coagido.
- **Derivados**: verifique `amounts`/`dates` etc. com valores concretos.
- **Completude do registry**: `expect(described_class::PERIOD_ADVANCE.keys).to match_array(Expense::INSTALLMENT_PERIODS)`.
- **AAA com linha vazia** entre Arrange/Act/Assert quando as três fases estão no `it`. Sem `let!`,
  sem comentários no spec.

Exemplo de exemplo positivo+negativo discriminante (fronteira MIN):

```ruby
it 'is valid at the MIN_INSTALLMENTS boundary' do
  plan = described_class.new(total_amount: 300, start_date: '2026-01-10',
                             period: 'monthly', repetitions: Expense::MIN_INSTALLMENTS)

  expect(plan.valid?).to be true
end

it 'is invalid below the MIN_INSTALLMENTS boundary' do
  plan = described_class.new(total_amount: 300, start_date: '2026-01-10',
                             period: 'monthly', repetitions: Expense::MIN_INSTALLMENTS - 1)

  expect(plan.valid?).to be false
end
```

---

## Anti-padrões

- Herdar de `ApplicationRecord` ou usar Dry::Struct — value object é Ruby puro.
- Persistir, chamar API ou abrir transação dentro do value object — isso é service.
- Formatar/apresentar (moeda, i18n, cor) — isso é component Phlex.
- Definir o limite `MAX_*`/`MIN_*` **só** no value object — ele mora no model AR; o VO referencia.
- Despachar variação com `case/when`/`if-elsif` em vez de registry congelado.
- Mutar uma instância — memoize derivados; para variar, construa outro.
- Namespace no singular (`module Expense`) — namespaces sempre no **plural**.
- Escrever comentário `#` no arquivo `.rb` — o nome de método/variável explica.
- Entregar o value object **sem** o spec dedicado.

---

## Checklist de revisão

**Value object**

- [ ] Em `app/models/<domínio>/`, namespace `module` no **plural**.
- [ ] Ruby puro (não `ApplicationRecord`, não Dry::Struct).
- [ ] `initialize` por keyword args, **coagindo** os inputs crus.
- [ ] Imutável: sem setters; derivados memoizados (`||=`); registries `.freeze`.
- [ ] Invariante via `valid?`; limites `MAX_*`/`MIN_*` referenciados do **model AR**.
- [ ] Variação por **registry** (`.fetch`), não `case/when`.
- [ ] Métodos só de consulta derivada; retorno **cru**, sem formatação/apresentação.
- [ ] Sem persistência, API, transação ou efeito colateral.
- [ ] Se é só dado estático, é `module` + constante congelada (sub-formato registry).

**Spec**

- [ ] Dedicado em `spec/models/<domínio>/<nome>_spec.rb`, sem factory, via `.new(...)`.
- [ ] Invariante nas duas fronteiras (`MIN`/`MAX`, ambos os lados), com constantes do model.
- [ ] Coerção, derivados e completude do registry cobertos.
- [ ] AAA com linha vazia; sem `let!`; sem comentários.
