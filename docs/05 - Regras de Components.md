
# Regras de Components

## Phlex em vez de ERB

Este projeto usa **Phlex** para todas as views. Não existem arquivos `.html.erb`. Views são classes Ruby que geram HTML via métodos.

```ruby
# app/components/card_component.rb

class CardComponent < ApplicationComponent
  def initialize(title:)
    @title = title
  end

  def view_template
    div(class: "bg-white rounded-lg shadow p-4") do
      h2(class: "text-lg font-semibold") { @title }
      yield  # slot para conteúdo filho
    end
  end
end
```

## Hierarquia

```
ApplicationComponent          # base de componentes (inclui helpers Rails)
└── CardComponent
└── ButtonComponent
└── StatCardComponent
└── StatsGridComponent
└── FABComponent              # floating action button
└── FilterComponent           # filtros de data/mês
└── FlashComponent            # notificações flash
└── LayoutComponent           # wrapper de página

ApplicationView               # base de views de página
└── Dashboard::IndexView
└── Expenses::NewView
└── Chat::IndexView
└── ...
```

## Regras de Componentes

### 1. Herança correta

- Componentes reutilizáveis → herdam `ApplicationComponent`
- Views de página → herdam `ApplicationView`
- Nunca herdar diretamente de `Phlex::HTML` — sempre via as bases do projeto

### 2. Atributos via `initialize`

```ruby
def initialize(title:, value:, trend: nil)
  @title = title
  @value = value
  @trend = trend
end
```

Todos os dados entram pelo construtor. Sem acesso direto a `params` ou `session` dentro do componente.

### 3. Tailwind para estilos

Todas as classes CSS vêm do Tailwind. Sem CSS inline e sem arquivos `.css` customizados (exceto via `tailwind.config.js`).

```ruby
div(class: "flex items-center gap-4 rounded-xl bg-white shadow-sm p-6")
```

Para classes condicionais, use o helper `class_names`:

```ruby
div(class: class_names("px-4 py-2", "font-bold" => @active, "opacity-50" => @disabled))
```

### 4. Concerns de View para comportamentos reutilizáveis

```
app/views/concerns/
├── modal_header.rb           # padrão de cabeçalho de modal
├── modal_styles.rb           # classes CSS de modal
├── button_styles.rb          # variantes de botão (primary, secondary, danger)
├── form_fields.rb            # campos de formulário padronizados
├── formatting.rb             # formatação de moeda (R$ 1.234,56)
├── turbo_create_response.rb  # template de resposta turbo para create
└── turbo_update_response.rb  # template de resposta turbo para update
```

Inclua concerns onde necessário:

```ruby
class Expenses::NewView < ApplicationView
  include Concerns::FormFields
  include Concerns::ModalStyles
end
```

### 5. Slots com `yield`

Componentes aceitam conteúdo filho via `yield`:

```ruby
# Definição

def view_template
  div(class: "card") do
    yield  # conteúdo vem de fora
  end
end

# Uso
render CardComponent.new(title: "Ganhos") do
  span { "R$ 1.500,00" }
end
```

## Turbo Streams

Respostas parciais via Turbo. O concern `RecordSaveResponse` cuida disso nos controllers.

```ruby
# Em controllers, via concern:

def handle_save_response(result)
  if result.success?
    render_turbo_success(result.expense)
  else
    render_turbo_errors(result.errors)
  end
end
```

Views de turbo stream ficam em `app/views/{recurso}/` com nome `create.turbo_stream.rb` ou `update.turbo_stream.rb`.

Patterns disponíveis via concerns de view:

```ruby
# TurboCreateResponse concern
def turbo_create_response(record, target:)
  turbo_stream.prepend(target, render(RecordRowComponent.new(record:)))
end

# TurboUpdateResponse concern
def turbo_update_response(record)
  turbo_stream.replace(dom_id(record), render(RecordRowComponent.new(record:)))
end
```

## Stimulus Controllers

Interatividade JavaScript via Stimulus. Arquivos em `app/javascript/controllers/`.

```javascript
// app/javascript/controllers/modal_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]

  open() { this.containerTarget.classList.remove("hidden") }
  close() { this.containerTarget.classList.add("hidden") }
}
```

Registrado automaticamente via `importmap.rb`.

## i18n em Views

Sempre use `t()` para strings visíveis ao usuário:

```ruby
# Errado
span { "Adicionar despesa" }

# Correto
span { t("expenses.add") }
```

Strings de UI ficam em `config/locales/pt-BR.yml` (ou arquivo específico do domínio).

## Relacionado

- [[01 - Arquitetura]]
- [[07 - Convenções]]
- [[03 - Regras de Testes]]
