# Referência — Components e Views (Phlex)

Detalhamento do padrão. Para a visão rápida, veja `SKILL.md`. Para código canônico, leia os
exemplares reais listados no `SKILL.md`.

---

## As duas bases

- **`ApplicationComponent < Phlex::HTML`** — base de todo component reutilizável. Já inclui os helpers
  Phlex::Rails (`Routes`, `DOMID`, `TurboFrameTag`, `LinkTo`, `T`, `L`) e o concern `Formatting`. Expõe
  `class_names(*classes)`, `helpers` (view_context) e `turbo_stream`.
- **`ApplicationView < ApplicationComponent`** — base das views de tela/resposta. Adiciona
  `FormWith`, `ButtonTo`, `ModalHeader`, `ModalStyles`, `FormFields`, `ButtonStyles`.

Regra: **component** é um pedaço de UI reutilizável (`StatCardComponent`); **view** é uma tela ou uma
resposta Turbo (`Earnings::CreateView`, que inclui um concern de resposta e renderiza streams). Component
não sabe de request; view orquestra a página/stream.

---

## Estrutura de um component

`initialize` por keyword args guarda ivars; `view_template` é o único método público de render; helpers
**privados** montam as strings de classe.

```ruby
class StatCardComponent < ApplicationComponent
  def initialize(title:, value:, color:, icon:, size: :default)
    @title = title
    @value = value
    @color = color
    @icon = icon
    @size = size
  end

  def view_template
    div(class: card_classes) do
      p(class: title_classes) { @title }
      p(class: value_classes) { @value }
    end
  end

  private

  def card_classes
    class_names('border-2 rounded-xl p-3 shadow-sm', colors[:bg], colors[:border])
  end
end
```

`class_names` junta e limpa `nil`/`false` — nunca interpole classe Tailwind com `nil` na mão.

---

## O lar da formatação de número

Formatação de moeda/percentual mora no concern `Formatting` (incluído na base), nunca `number_to_currency`
cru repetido:

```ruby
module Formatting
  include ActionView::Helpers::NumberHelper

  def format_currency(value)
    number_to_currency(value, unit: 'R$ ', format: '%u%n', separator: ',', delimiter: '.', precision: 2)
  end

  def format_percentage(value)
    number_with_precision(value, precision: 1)
  end
end
```

O service devolve `BigDecimal`/`Integer` cru; o component chama `format_currency(@value)`. Se você viu
`number_to_currency` fora de `Formatting`, centralize lá.

---

## Cor e paleta = registry com default (OCP)

Cor/token de design é resolvido por um **mapa congelado** com fallback — um registry. Nunca `if color ==
:green … elsif …`.

```ruby
COLORS = { green: { bg: 'bg-green-50', ... }, red: { bg: 'bg-red-50', ... } }.freeze

def colors
  @colors ||= COLORS.fetch(@color, default_colors)
end
```

Paletas compartilhadas entre components são **concerns** em `app/components/concerns/` com constantes
`DEFAULT_*`:

```ruby
module PlatformPalette
  PLATFORM_META = { 'uber' => { color: '#000000', fg: '#ffffff' }, ... }.freeze
  DEFAULT_COLOR = '#94a3b8'

  def platform_color(platform) = PLATFORM_META.dig(platform, :color) || DEFAULT_COLOR
end
```

Adicionar uma variante de cor = uma entrada no mapa. O `.fetch(chave, default)`/`.dig || DEFAULT`
garante fallback sem `case/when`.

---

## Protótipo React = única fonte da verdade visual

**Nunca implemente UI de memória.** O protótipo React é a única verdade para qualquer decisão visual.
Arquivos em `/home/rebase/Downloads/Cosmic scale animation/`:

- `screen-[nome].jsx` — layout mobile de cada tela.
- `screens-desktop.jsx` — layout desktop de todas as telas.
- `lib.jsx` — componentes compartilhados (BRL, Icon…).

Regras por fase (do `CLAUDE.md`):

- **Discovery**: ler `screen-[nome].jsx` e a seção em `screens-desktop.jsx`; extrair classes Tailwind,
  valores exatos, grid e nomes de ícone.
- **Plan**: cada decisão visual cita arquivo e linha de origem (`screens-desktop.jsx:444`).
- **Execute**: antes de fechar, screenshot da tela e comparação item a item; só concluir sem divergência.

---

## Padrão de spec (component)

Spec em `spec/components/<nome>_component_spec.rb`, `type: :component`. Renderiza via
`view_context.render(described_class.new(...))` e afirma sobre o HTML de saída.

```ruby
RSpec.describe StatCardComponent, type: :component do
  describe '#view_template' do
    it 'renders as link when href is provided' do
      html = view_context.render(described_class.new(title: 'T', value: 'V', color: :green, icon: nil, href: '/test'))

      expect(html).to include('<a')
      expect(html).to include('href="/test"')
    end

    it 'uses rounded-xl and p-3 for the card container' do
      html = view_context.render(described_class.new(title: 'T', value: 'V', color: :green, icon: nil))

      expect(html).to include('rounded-xl')
      expect(html).not_to include('rounded-lg')
    end
  end
end
```

Cobrir: render do conteúdo, ramos condicionais (link vs div, com/sem ícone), e os **design tokens**
exatos do protótipo (`rounded-xl`, `p-3`, `text-xl`). O `not_to include` de um token oposto é o par
discriminante do positivo — legítimo. Regras gerais em **arch-spec**.

---

## Anti-padrões

- ERB — a camada é 100% Phlex (`.rb`).
- `number_to_currency`/formatação de número fora do concern `Formatting`.
- Cor/token via `case/when`/`if-elsif` em vez de mapa congelado com `.fetch(chave, default)`.
- Interpolar classe Tailwind com `nil` à mão em vez de `class_names`.
- Cálculo de domínio ou acesso a banco dentro do component — isso é service/presenter.
- String visível hardcoded em vez de `t(...)` do `pt-BR.yml`.
- Implementar layout **de memória** em vez de ler o protótipo React.
- Escrever comentário `#` no arquivo `.rb`; ou entregar o component **sem** o spec.

---

## Checklist de revisão

**Component / View**

- [ ] Herda de `ApplicationComponent` (reutilizável) ou `ApplicationView` (tela/resposta); zero ERB.
- [ ] `initialize` por keyword; `view_template` público; helpers de classe **privados**.
- [ ] Moeda/percentual via `Formatting`; nunca `number_to_currency` cru espalhado.
- [ ] Cor/token via mapa congelado `.fetch(chave, default)`; paleta compartilhada como concern com `DEFAULT_*`.
- [ ] Classes via `class_names`; string visível via `t`.
- [ ] Layout conferido **contra o protótipo React** (arquivo:linha), não de memória.
- [ ] Sem cálculo de domínio nem acesso a banco no arquivo.

**Spec**

- [ ] Em `spec/components/<nome>_component_spec.rb`, `type: :component`, via `view_context.render`.
- [ ] Conteúdo, ramos condicionais e design tokens exatos cobertos.
- [ ] Segue **arch-spec** (sem `let!`, AAA com linha vazia, sem comentários, cobertura 100%).
