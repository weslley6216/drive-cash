---
name: arch-value-object
description: Use when creating, altering, or reviewing a domain value object in DriveCash — a plain immutable Ruby class or data module under app/models/<domain>/ that carries an invariant or derives values with no persistence and no side effects (e.g. Expenses::InstallmentPlan, Exports::PeriodRange, Plans::Catalog). Use when deciding whether logic belongs in a value object, a service, or a pure calculator, or where a business limit like MAX_INSTALLMENTS should live. Takes precedence over divergent legacy code.
---

# Skill: Value Objects de domínio

## Propósito

Referência de como o DriveCash modela **value objects** da camada de domínio. Use ao **criar**,
**alterar** ou **revisar** um value object (e seu spec) para garantir aderência ao padrão.

Um value object é **dado de domínio imutável com invariante própria**: nomeia um conceito do
domínio, recebe dados crus, **coage** na construção, **valida** sua invariante e responde
**consultas derivadas**. Ele **NÃO** persiste, **NÃO** tem efeito colateral (sem banco, sem API,
sem transação) e **NÃO** apresenta (sem `number_to_currency`, sem cor/token, sem rótulo i18n). A
apresentação fica no component Phlex; a orquestração com efeito colateral fica no service.

## Quando usar

- Vou criar/alterar/revisar um value object ou seu spec.
- Estou em dúvida se a lógica vai num **value object**, num **service** ou num **calculador puro**.
- Preciso decidir **onde mora um limite de negócio** (`MAX_*`, `MIN_*`).

## Onde a lógica mora (a decisão que erra fácil)

| Se… | Vai para | Onde |
|-----|----------|------|
| Nomeia um conceito de domínio, tem invariante, imutável, sem banco | **Value object** | `app/models/<domínio>/` |
| Orquestra, persiste, abre transação, chama API | **Service** | `app/services/<domínio>/` |
| Calcula um passo puro **sem** invariante própria | **Calculador puro** | `app/services/<domínio>/` (ex.: `Dashboard::PercentChange`) |
| É dado de referência estático, sem comportamento | **Módulo-registry** | `app/models/<domínio>/` (ex.: `Plans::Catalog`) |

Regra-chave: se carrega **invariante** e nomeia um **conceito**, é value object e vive em
`models/`. Calculador de passo sem invariante pode seguir em `services/`.

## Convenções essenciais

| Aspecto | Regra |
|---------|-------|
| Arquivo / namespace | `app/models/<domínio-plural>/<nome>.rb`; `module` no **plural** (`module Expenses`) |
| Base | **Ruby puro** — nunca `< ApplicationRecord`, nunca Dry::Struct |
| Construção | `initialize` por **keyword args**; **coage os inputs crus** aqui (`BigDecimal(x.to_s)`, `parse_date`, `.to_s`, `.to_i`) |
| Imutabilidade | sem setters; derivados memoizados com `||=`; registries `.freeze` |
| Invariante | predicado `valid?`; **os limites `MAX_*`/`MIN_*` moram no model AR** — o VO só **referencia** (`Expense::MAX_INSTALLMENTS`) |
| Variação de domínio | **registry** (hash congelado, às vezes de lambdas) resolvido por chave — nunca `case/when` (OCP) |
| Métodos | apenas **consultas derivadas puras**; retornam **dado cru** (BigDecimal, Date, hash) — zero formatação/apresentação |
| Sub-formato dados | quando não há comportamento, um `module` com constante congelada (`Catalog`) — sem instância |
| Spec | dedicado, sem factory, `.new(...)`, AAA com linha vazia; cobre fronteiras `valid?`, coerção, derivados e completude do registry |

## Exemplares reais (canônicos, atuais)

Leia o código real destes antes de escrever um novo — são a fonte, não este texto:

- **`app/models/expenses/installment_plan.rb`** — o mais completo: invariante (`valid?` referenciando
  `Expense::MIN/MAX_INSTALLMENTS`), registry de lambdas (`PERIOD_ADVANCE`), coerção no `initialize`,
  derivados memoizados (`amounts`, `dates`).
- **`app/models/exports/period_range.rb`** — mais simples: registry (`PERIODS`), sem invariante,
  duas queries (`period_start`/`period_end`).
- **`app/models/plans/catalog.rb`** — sub-formato **módulo-registry de dados** (`PLANS` congelado),
  sem instância nem comportamento.

## Arquivos desta skill

Leia sob demanda:

- **`reference.md`** — detalhamento: os dois sub-formatos, a regra do limite no model AR, registry/OCP,
  padrão de spec, anti-padrões e checklist de revisão.
- **`template.rb`** — esqueleto para iniciar um value object comportamental.

## Fluxo sugerido

1. **Criar**: confirme na tabela "Onde a lógica mora" que é mesmo value object. Parta de `template.rb`
   (ou do exemplar mais próximo), ajuste namespace/atributos, coloque o limite no model AR se houver
   invariante. Crie o spec dedicado no padrão de `installment_plan_spec.rb`.
2. **Alterar**: mude construção/invariante/derivados e **atualize o spec na mesma mudança**.
3. **Revisar**: rode o checklist de `reference.md` contra o value object e o spec.
