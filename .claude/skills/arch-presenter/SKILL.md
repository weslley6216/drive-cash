---
name: arch-presenter
description: Use when creating, altering, or reviewing a presenter in DriveCash — a class or module under app/presenters/<domain>/ that turns a service's raw payload into view-ready data (a hash or Data) for a Phlex view, sitting between service and component. Use for the one-presenter-class-per-variant registry resolved by convention (const_get(type.camelize) or constantize), a shared Base that includes Formatting, and the producer/presenter coverage guarantee. Covers Dashboard::Insights::Presenters, Notifications::Presenters, History::EntryRows, Chat::Answers, Chat::Summaries. NOT for HTML/Tailwind rendering (that is arch-component) or domain calculation (arch-service). Takes precedence over divergent legacy code.
---

# Skill: Presenters

## Propósito

Referência de como o DriveCash modela a camada de **presenter** — o adaptador entre o payload cru do
service e a view Phlex. Use ao **criar**, **alterar** ou **revisar** um presenter (e seu spec).

Um presenter recebe o **dado cru** do service e devolve um **payload view-ready** (hash ou `Data`) que a
view Phlex consome. É o **lar dos registries "um presenter por variante"**: conjunto de apresentação que
cresce (tipo de insight, kind de notificação, resposta de chat, linha de histórico) despacha por **uma
classe por variante resolvida por convenção** — nunca `case/when`.

## Quando usar

- Vou criar/alterar/revisar um presenter ou seu spec.
- Tenho um conjunto de apresentação que **cresce por variante** (insight, notificação, resposta de chat).
- Preciso adaptar o payload de um service para uma view sem espalhar `if tipo == ...`.

## Presenter × Service × Component (a decisão que erra fácil)

| Se… | Vai para | Onde |
|-----|----------|------|
| Adapta payload cru do service → dado view-ready (título/descrição/ícone por variante) | **Presenter** | `app/presenters/<domínio>/` |
| Calcula/agrega/persiste/orquestra | **Service** | `app/services/<domínio>/` → **arch-service** |
| Renderiza HTML/Tailwind | **Component/View** | `app/components/` · `app/views/` → **arch-component** |

O presenter fica **entre** os dois: resolve *qual* apresentação para *qual* variante e monta o dado; a
view desenha. Formatação pontual (moeda, data i18n, título traduzido) pode acontecer aqui, via `Formatting`.

## Convenções essenciais

| Aspecto | Regra |
|---------|-------|
| Namespace / dir | `module <Domínio-plural>` em `app/presenters/<domínio>/`; sempre plural |
| Registry por convenção | módulo com `self.present(raw)` / `self.for(record)` que resolve a **classe da variante** por convenção: `const_get(raw[:type].camelize)`, `constantize` — depois `.new(...).call` |
| Uma classe por variante | cada variante é uma **classe própria** (arquivo próprio) que herda de um `Base` da família — nunca `case/when` no dispatcher |
| `Base` compartilhado | `include Formatting`; `initialize(raw/record)`; `call` devolve o payload view-ready; helpers `payload`/`translate` privados |
| Variante | subclasse que define **só** o que difere (`title`, `description`, `icon`, `palette_key`) |
| Retorno | hash com chaves estáveis **ou** `Data.define(...)` (`Row`) — dado que a view consome direto |
| Formatação | pode formatar aqui (`format_currency`, `I18n.l`, `translate`) — é camada de apresentação; cor/token de design fica no component |
| Completude | spec garante **um presenter por variante** que o produtor emite (`const_defined?` para cada regra/kind) |
| Spec | por família via `.present`/`.for`, afirmando sobre o payload; regras gerais em **arch-spec** |

## Exemplares reais (canônicos, atuais)

Leia o código real destes antes de escrever um novo:

- **`app/presenters/dashboard/insights/presenters.rb`** + **`presenters/base.rb`** + **`presenters/best_day.rb`**
  — o padrão completo: dispatcher `self.present` via `const_get(raw[:type].camelize)`, `Base` com
  `Formatting`/`translate`, variante que define só `title`/`description`.
- **`app/presenters/notifications/presenters.rb`** — dispatcher via `const_get(kind.camelize, false)`,
  retorno `Row = Data.define(...)`.
- **`app/presenters/history/entry_rows.rb`** — dispatcher via `constantize` a partir de `record.class.name`.

## Arquivos desta skill

Leia sob demanda:

- **`reference.md`** — detalhamento: dispatcher por convenção, `Base` + variante, o retorno hash/`Data`,
  a garantia de completude produtor/presenter, padrão de spec, anti-padrões e checklist.
- **`template.rb`** — esqueleto de uma família de presenter (dispatcher + `Base` + uma variante).

## Fluxo sugerido

1. **Criar**: confirme que é um conjunto de apresentação que cresce por variante. Parta de `template.rb`
   (ou de `dashboard/insights/presenters/`). Crie o dispatcher, o `Base` e uma classe por variante. Crie
   o spec com o teste de **completude produtor/presenter**.
2. **Alterar**: adicione a variante como **nova classe** (nunca editar o dispatcher) e cubra no spec.
3. **Revisar**: rode o checklist de `reference.md` contra o presenter e o spec.
