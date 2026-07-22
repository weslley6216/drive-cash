# Referência — Presenters

Detalhamento do padrão. Para a visão rápida, veja `SKILL.md`. Para código canônico, leia os
exemplares reais listados no `SKILL.md`.

---

## O dispatcher resolvido por convenção (registry OCP)

O ponto de entrada da família é um módulo com um método `self.present` / `self.for` que resolve a
**classe da variante por convenção** — a partir de um `type`, de um `kind` ou da classe do registro — e
delega. Nenhum `case/when`.

```ruby
module Dashboard
  module Insights
    module Presenters
      def self.present(raw)
        const_get(raw[:type].camelize).new(raw).call
      end
    end
  end
end
```

Três formas de convenção em uso, todas equivalentes:

- `const_get(raw[:type].camelize)` — a partir de uma string de tipo (`'best_day'` → `BestDay`).
- `const_get(notification.kind.camelize, false)` — a partir de um `kind` de model.
- `"History::EntryRows::#{record.class.name}".constantize` — a partir da classe do registro.

Adicionar uma variante = criar **uma classe nova** com o nome que a convenção espera. O dispatcher nunca
muda — é OCP puro.

---

## `Base` + variante (SRP dentro do OCP)

Cada família tem um `Base` que centraliza o esqueleto do payload e as ferramentas de apresentação; cada
variante herda e define **só o que difere**.

```ruby
class Base
  include Formatting

  I18N_SCOPE = 'analysis.show_view.insights'

  def initialize(raw)
    @raw = raw
  end

  def call
    { type: @raw[:type], severity: @raw[:severity], title: title, description: description }
  end

  private

  def payload = @raw[:payload]

  def translate(key, **options)
    I18n.t("#{I18N_SCOPE}.#{@raw[:type]}.#{key}", **options)
  end
end

class BestDay < Base
  private

  def title       = translate('title', value: format_currency(payload[:amount]))
  def description = translate('description', date: I18n.l(payload[:date], format: :default))
end
```

O `Base` define o **contrato de saída** (as chaves do hash / o shape do `Data`); a variante preenche os
pontos que variam. É SRP dentro do OCP: o dispatcher referencia as variantes, o `Base` compartilha o
comum, a variante isola a diferença.

---

## O retorno: hash ou `Data`

O presenter devolve **dado view-ready** — não HTML. Duas formas:

- **hash de chaves estáveis** (`{ type:, severity:, title:, description: }`) — `Dashboard::Insights`.
- **`Data.define`** quando o conjunto de campos é fixo — `Notifications::Presenters::Row =
  Data.define(:notification, :title, :body, :icon, :palette_key)`.

Pode conter strings já formatadas/traduzidas (é camada de apresentação). O que **não** vai aqui: markup,
classe Tailwind, cor/token de design — isso é do component (que recebe este payload).

---

## Completude produtor/presenter (a garantia que falta fácil)

Como o dispatch é por convenção (não um hash explícito), o risco é um produtor emitir uma variante **sem**
presenter correspondente — que só quebraria em runtime. O spec fecha isso afirmando que existe um
presenter para **cada** variante que o produtor emite:

```ruby
it 'defines a presenter for every insight rule emitted by InsightsService' do
  Dashboard::InsightsService::INSIGHT_RULES.each do |rule|
    expect(described_class.const_defined?(rule.name.demodulize)).to be(true)
  end
end
```

Todo presenter com dispatch por convenção precisa desse teste de completude contra a fonte que produz as
chaves (o service/registry produtor).

---

## Padrão de spec

Spec em `spec/presenters/<domínio>/<nome>_spec.rb`. Testa a família pelo dispatcher (`.present`/`.for`),
alimentando o payload cru e afirmando sobre o payload view-ready. Não precisa de banco quando o `raw` é
construído à mão.

```ruby
RSpec.describe Dashboard::Insights::Presenters do
  describe '.present' do
    it 'renders best_day with formatted amount and localized date' do
      date = Date.new(2025, 6, 10)
      raw = { type: 'best_day', severity: 'info', payload: { date: date, amount: 500.0 } }

      result = described_class.present(raw)

      expect(result[:title]).to include('500,00')
      expect(result[:description]).to include(I18n.l(date, format: :default))
    end
  end
end
```

Cobrir: cada variante pelo `.present`, os ramos internos de cada variante (ex.: `monthly` vs `annual`,
com o par positivo+negativo discriminante) e o teste de **completude produtor/presenter**. Regras gerais
(sem `let!`, AAA com linha vazia, sem comentários, cobertura 100%) em **arch-spec**.

---

## Anti-padrões

- Dispatcher com `case/when`/`if-elsif` por tipo em vez de resolução por convenção.
- Editar o dispatcher para adicionar variante, em vez de só criar a classe da variante.
- Presenter devolvendo HTML/Tailwind/cor — isso é component.
- Cálculo/agregação de domínio dentro do presenter — isso é service.
- Duplicar o esqueleto do payload em cada variante em vez de um `Base` compartilhado.
- Omitir o teste de **completude produtor/presenter** num dispatch por convenção.
- Namespace no singular; comentário `#` no `.rb`; entregar o presenter **sem** o spec.

---

## Checklist de revisão

**Presenter**

- [ ] `module <Domínio-plural>` em `app/presenters/<domínio>/`.
- [ ] Dispatcher `self.present`/`self.for` resolve a variante **por convenção** (`const_get`/`constantize`), sem `case/when`.
- [ ] Uma **classe por variante** herdando de um `Base` compartilhado; variante define só o que difere.
- [ ] `Base` inclui `Formatting`; `call` devolve hash/`Data` view-ready com chaves estáveis.
- [ ] Sem HTML/Tailwind/cor (component) e sem cálculo de domínio (service).

**Spec**

- [ ] Em `spec/presenters/<domínio>/`, testa via `.present`/`.for` afirmando sobre o payload.
- [ ] Ramos de cada variante cobertos (par positivo+negativo quando condicional).
- [ ] Teste de **completude produtor/presenter** presente.
- [ ] Segue **arch-spec** (sem `let!`, AAA com linha vazia, sem comentários, cobertura 100%).
