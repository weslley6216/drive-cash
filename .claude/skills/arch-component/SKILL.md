---
name: arch-component
description: Use when creating, altering, or reviewing a Phlex component or view in DriveCash — a Ruby class under app/components/ (reusable UI, ApplicationComponent) or app/views/ (page/response-level, ApplicationView) that renders HTML with the Phlex DSL and never ERB. Use for view_template, the presentation home of number_to_currency/format_currency, color and design tokens, palette lookup registries with a default (PlatformPalette, StatCardComponent COLORS), Tailwind class_names helpers, and honoring the React prototype as the single visual source of truth. NOT for business logic (that is arch-service) or raw domain data prep (arch-presenter). Takes precedence over divergent legacy code.
---

# Skill: Components e Views (Phlex)

## Propósito

Referência de como o DriveCash modela a camada de **apresentação** — os componentes e views Phlex. Use
ao **criar**, **alterar** ou **revisar** um component/view (e seu spec) para garantir aderência ao padrão.

Phlex, **nunca ERB**: views e components são arquivos `.rb` que herdam de `ApplicationView` ou
`ApplicationComponent` e renderizam HTML com a DSL Phlex (`div`, `p`, `a`). Este é o **lar da
apresentação**: `number_to_currency`/`format_currency`, cor, design token, classe Tailwind e i18n
visível moram aqui — e em lugar nenhum antes daqui.

## Quando usar

- Vou criar/alterar/revisar um component ou view Phlex (e seu spec).
- Preciso formatar moeda/percentual, aplicar cor/token de design ou montar classe Tailwind.
- Preciso renderizar um pedaço de UI reutilizável ou uma resposta/página inteira.

## Component × View × Presenter (a decisão que erra fácil)

| Se… | Vai para | Onde |
|-----|----------|------|
| Pedaço de UI **reutilizável** (card, chip, botão) | **Component** | `app/components/<nome>_component.rb` (`< ApplicationComponent`) |
| Página ou resposta Turbo de nível de tela | **View** | `app/views/<domínio>/<nome>_view.rb` (`< ApplicationView`) |
| Preparar **dado cru** do service para a view (sem HTML) | **Presenter** | `app/presenters/` → **arch-presenter** |
| Calcular/persistir/orquestrar | **Service** | `app/services/<domínio>/` → **arch-service** |

## Convenções essenciais

| Aspecto | Regra |
|---------|-------|
| Base | Component `< ApplicationComponent` (`Phlex::HTML` + helpers); View `< ApplicationView` (adiciona FormWith/ButtonTo/Modal/FormFields) |
| Nunca ERB | HTML só via DSL Phlex no `view_template`; arquivo `.rb` |
| Construção | `initialize(keyword:)` guarda ivars; `view_template` renderiza; helpers **privados** montam classes |
| Formatação de número | **`Formatting`** (já incluído): `format_currency`, `format_currency_short`, `format_percentage` — nunca `number_to_currency` cru espalhado |
| Cor / design token | mapa `COLORS`/paleta **congelado** resolvido por `.fetch(chave, default)` — é um registry com fallback (OCP) |
| Paletas compartilhadas | concerns em `app/components/concerns/` (`PlatformPalette`, `CategoryPalette`, `MaintenancePalette`, `ButtonStyles`, `ModalStyles`) com `DEFAULT_*` |
| Classes Tailwind | `class_names(*classes)` para juntar/condicionar; nunca interpolar string solta com `nil` |
| i18n visível | via helper `t`/`l`; toda string visível vem de `pt-BR.yml` |
| Fonte da verdade visual | **protótipo React** é a única verdade: `screen-[nome].jsx`, `screens-desktop.jsx`, `lib.jsx` — nunca implementar UI de memória |
| Spec | `type: :component`, `view_context.render(described_class.new(...))` → `expect(html).to include(...)`; regras gerais em **arch-spec** |

## Exemplares reais (canônicos, atuais)

Leia o código real destes antes de escrever um novo:

- **`app/components/application_component.rb`** / **`app/views/application_view.rb`** — as duas bases e o
  que cada uma traz (`class_names`, `helpers`, `turbo_stream`; e Form/Modal helpers na View).
- **`app/components/stat_card_component.rb`** — component canônico: registry `COLORS`/`SIZES` resolvido
  por `.fetch(chave, default)`, `initialize` por keyword, `view_template` + helpers de classe privados.
- **`app/components/concerns/platform_palette.rb`** — paleta compartilhada (mapa congelado + `DEFAULT_*`,
  lookup por `.dig || default`).
- **`app/views/concerns/formatting.rb`** — o lar de `format_currency`/`format_percentage`.
- **`app/views/earnings/create_view.rb`** — view de nível de resposta (Turbo), herda de `ApplicationView`.

## Arquivos desta skill

Leia sob demanda:

- **`reference.md`** — detalhamento: bases Component/View, o lar da formatação, paletas como registry com
  default, DSL Phlex, protótipo como fonte da verdade, padrão de spec, anti-padrões e checklist.
- **`template.rb`** — esqueleto de um component com registry de cor e formatação.

## Fluxo sugerido

1. **Criar**: **leia o protótipo** (`screen-[nome].jsx` + `screens-desktop.jsx`) e extraia classes/valores
   exatos — nunca de memória. Decida component (reutilizável) vs view (tela/resposta). Parta de
   `template.rb` ou do exemplar mais próximo. Crie o spec no padrão de `stat_card_component_spec.rb`.
2. **Alterar**: mude o `view_template`/helpers e **atualize o spec na mesma mudança**; compare com o protótipo.
3. **Revisar**: rode o checklist de `reference.md`; tire screenshot e compare item a item com o protótipo.
