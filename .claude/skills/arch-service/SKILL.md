---
name: arch-service
description: Use when creating, altering, or reviewing a service object in DriveCash — a class under app/services/<domain>/ that orchestrates a use case with a side effect (persists, opens a transaction, calls the Groq/Gemini API) or is a pure step-calculator, returning a semantic payload (a Data or hash of raw values), never presentation. Use for Creator/Updater/*Service/*Calculator classes, the self.call entry point, OCP registries (Ai::Tools::Registry, History::FeedService::FILTERS), and thin jobs over services. NOT for persistence models (arch-model), value objects with invariants (arch-value-object), or view formatting (arch-component). Takes precedence over divergent legacy code.
---

# Skill: Services

## Propósito

Referência de como o DriveCash modela a camada de **service** — orquestração de casos de uso. Use ao
**criar**, **alterar** ou **revisar** um service (e seu spec) para garantir aderência ao padrão.

Um service **orquestra** e normalmente tem **efeito colateral**: persiste, abre transação, chama a API
(Groq/Gemini). Ele devolve um **payload semântico** — estrutura + dado cru (números, chaves de enum,
`Data`/hash) — **nunca** apresentação (`number_to_currency`, cor, i18n visível ficam no component).
Cálculo de domínio **não convive com formatação** no mesmo arquivo; e conjunto que cresce despacha por
**registry**, nunca `case/when`.

## Quando usar

- Vou criar/alterar/revisar um service ou seu spec.
- Estou implementando um caso de uso com efeito colateral (persistir, transação, API externa).
- Preciso de um **calculador** de domínio ou de um **registry** para variação que cresce (OCP).

## Service, model, value object ou calculador (a decisão que erra fácil)

| Se… | Vai para | Onde |
|-----|----------|------|
| Orquestra um caso de uso **com efeito colateral** (persiste, transação, API) | **Service** | `app/services/<domínio>/` |
| Calcula um passo puro **sem** invariante própria (agregação, derivação) | **Calculador (service)** | `app/services/<domínio>/` (ex.: `Refuelings::VendorEfficiency`) |
| Nomeia um conceito, imutável, **com** invariante, sem banco | **Value object** | `app/models/<domínio>/` → **arch-value-object** |
| Persiste, mapeia tabela, tem enum/validação/scope | **Model AR** | `app/models/<singular>.rb` → **arch-model** |
| Formata/apresenta (moeda, cor, i18n visível) | **Component Phlex** | `app/components/` → **arch-component** |

## Convenções essenciais

| Aspecto | Regra |
|---------|-------|
| Namespace / arquivo | `module <Domínio-plural>` (**sempre plural**); `app/services/<domínio>/<nome>.rb` |
| Entry point | `self.call(args, keyword:)` que delega a `new(...).call`; `initialize` guarda, `call` orquestra |
| Retorno | **payload semântico**: `Result = Data.define(...)` ou hash de **dado cru**; nunca `Data.define` com string formatada |
| Sem apresentação | zero `number_to_currency`/cor/token/i18n visível — isso é component; rótulo i18n 1:1 (`platforms.#{platform}`) **pode** ficar no service |
| Cálculo × formatação | nunca no mesmo arquivo; cálculo puro extrai para calculador (`Refuelings::VendorEfficiency`, `Dashboard::EarningsCalculator`) |
| Variação que cresce (OCP) | **registry** (hash/array congelado de `Data`) resolvido por `.fetch`/`.find` — nunca `case/when` espalhado |
| Limite de negócio | invariante de registro (`MAX_*`) mora no **model**; o service referencia. Constante só-de-service (`MIN_DISTINCT_VENDORS`) é threshold do próprio cálculo, ok |
| Isolamento de usuário | opera sempre por `@user.earnings.new(...)` (scoping por associação), descartando `user_id` forjado no payload |
| Job | casca fina sobre Solid Queue: acha o registro, muda status, chama o service, trata `rescue` → `failed` + `raise` |
| Spec | `require 'rails_helper'`, FactoryBot + banco, `describe '.call'`, afirma sobre o **payload/estado persistido**; regras gerais em **arch-spec** |

## Exemplares reais (canônicos, atuais)

Leia o código real destes antes de escrever um novo:

- **`app/services/earnings/creator.rb`** — o creator canônico: `self.call` → `new.call`, persiste via
  `@user.earnings.new`, devolve `Result = Data.define(:success?, :earning)`, descarta `user_id` forjado.
- **`app/services/refuelings/vendor_efficiency.rb`** — calculador puro (sem efeito colateral): threshold
  em constante, derivados memoizados, devolve `Comparison = Data.define(...)` de dado cru.
- **`app/services/history/feed_service.rb`** — registry `FILTERS` (`Data` de lambdas) com `.fetch` e
  default; devolve hash (`groups`/`summary`) de dado cru.
- **`app/services/ai/tools/registry.rb`** — o registry OCP grande: `TOOLS`/`QUERY_KINDS` congelados,
  uma entrada por variante, **referenciando** colaboradores (persister, presenter) sem contê-los.
- **`app/jobs/export_job.rb`** — job casca fina: acha `Export`, muda status, chama `Exports::Builder` +
  `Exports::Registry`, anexa arquivo, `rescue` → `failed` + `raise`.

## Arquivos desta skill

Leia sob demanda:

- **`reference.md`** — detalhamento: entry point `self.call`, payload semântico, a linha cálculo×formatação,
  registry/OCP, isolamento de usuário, job casca fina, padrão de spec, anti-padrões e checklist.
- **`template.rb`** — esqueleto de um service de caso de uso com efeito colateral.

## Fluxo sugerido

1. **Criar**: confirme na tabela que é mesmo service (tem efeito colateral) e não value object/calculador.
   Parta de `template.rb` (ou do exemplar mais próximo). Se o caso de uso cresce por variantes, use
   registry. Crie o spec no padrão de `spec/services/earnings/creator_spec.rb`.
2. **Alterar**: mude a orquestração/payload e **atualize o spec na mesma mudança**.
3. **Revisar**: rode o checklist de `reference.md` contra o service e o spec.
