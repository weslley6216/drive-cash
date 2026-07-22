---
name: arch-model
description: Use when creating, altering, or reviewing an ActiveRecord model in DriveCash — a class that inherits from ApplicationRecord and persists to a table (Expense, Earning, Goal, Vehicle, Maintenance, Refueling, Export, Notification, User). Use for enums, validates, associations (has_many/belongs_to/has_one), scopes, callbacks, business-limit constants (MAX_INSTALLMENTS), the FinancialEntry/MonetaryAmount/VendorNormalization concerns, and factory-based model specs. NOT for plain immutable Ruby value objects with no persistence (that is arch-value-object). Takes precedence over divergent legacy code.
---

# Skill: Models ActiveRecord

## Propósito

Referência de como o DriveCash modela a camada de **persistência** — os models `ActiveRecord`. Use ao
**criar**, **alterar** ou **revisar** um model (e seu spec) para garantir aderência ao padrão.

Um model AR é **persistência + invariante de registro**: herda de `ApplicationRecord`, mapeia uma
tabela, declara `enum`/associação/scope/`validates`, é **dono** das constantes de limite de negócio
(`MAX_*`/`MIN_*`) e expõe consultas derivadas do **próprio estado persistido**. Ele **NÃO** orquestra
efeito colateral entre vários models (isso é service), **NÃO** apresenta (moeda/cor/i18n visível ficam
no component Phlex) e **NÃO** é um value object puro (imutável, sem banco).

## Quando usar

- Vou criar/alterar/revisar um model AR ou seu spec.
- Estou em dúvida se a lógica vai num **model**, num **value object** ou num **service**.
- Preciso decidir sobre **enum**, **associação**, **scope**, **validação** ou onde mora um **limite de negócio**.

## Model, value object ou service (a decisão que erra fácil)

| Se… | Vai para | Onde |
|-----|----------|------|
| Persiste, mapeia tabela, tem enum/validação/associação/scope | **Model AR** | `app/models/<singular>.rb` |
| Deriva do **próprio estado já carregado** (predicado, cálculo simples de 1 passo) | **Método no model** | o próprio model |
| Nomeia um conceito, imutável, com invariante, **sem** banco | **Value object** | `app/models/<domínio-plural>/` → veja **arch-value-object** |
| Orquestra, persiste em várias tabelas, abre transação, chama API | **Service** | `app/services/<domínio>/` |
| Cálculo de domínio **pesado** (mesmo derivando de um model) | **Calculador puro / service** | `app/services/<domínio>/` (ex.: `Vehicles::MaintenanceService`) |

Regra-chave de nomenclatura: o model AR é `class Expense` — **singular, top-level**. O **namespace**
dos colaboradores do domínio (value objects, services, presenters) é **plural** (`Expenses::`). Nunca
reusar `Expense` como módulo (`module Expense`) — dá `TypeError: Expense is not a module`.

## Convenções essenciais

| Aspecto | Regra |
|---------|-------|
| Arquivo / classe | `app/models/<singular>.rb`; `class Expense < ApplicationRecord` — **singular, top-level** |
| Base | `< ApplicationRecord` (traz `human_enum_name` para rótulo i18n de enum) |
| Enum inteiro | `enum :attr, { key: 0, ... }, prefix: true` com valores **explícitos**; `validate: true` (ou `{ allow_nil: true }`) quando precisa validar o domínio |
| Enum string | constante `KINDS = %w[...].freeze` + `enum :kind, KINDS.zip(KINDS).to_h, prefix: true` |
| Conjunto que **cresce** | não-enum: string + `inclusion: { in: <Registry>::KINDS }` (ex.: `Notification.kind`) — registry no service (OCP) |
| Concerns | `FinancialEntry` (user + `monetize :amount` + scopes financeiros, para Expense/Earning), `MonetaryAmount` (`monetize`), `VendorNormalization` — cross-cutting **não é camada** |
| Limite de negócio | `MAX_*`/`MIN_*` = constante do model + `validates` correspondente — o model é o **dono do invariante**; o value object só **referencia** |
| Monetário | coluna `decimal(10,2)`; `monetize :attr` converte string BR (`"45,90"` → `45.90`) |
| Associações | `belongs_to`/`has_many`/`has_one` sempre com `dependent:` explícito (`:destroy` ou `:nullify`) |
| Scopes | lambda **chainable**; compõe outros scopes; nunca lógica de apresentação |
| Validação cross-field | `validate :metodo` privado; `errors.add(:campo, :chave_i18n)` — **símbolo**, nunca string literal |
| Callbacks | `before_validation`/`before_save`/`after_initialize` para normalização e defaults |
| Método de domínio | consulta derivada do **próprio estado** (`#installment?`, `#ended?`, `#progress`); cálculo pesado **extrai** para service |
| Spec | **com FactoryBot** (`build`/`create`, ≠ `.new` do value object), shoulda-matchers, `describe` por aspecto; regras gerais de RSpec em **arch-spec** |

## Exemplares reais (canônicos, atuais)

Leia o código real destes antes de escrever um novo — são a fonte, não este texto:

- **`app/models/expense.rb`** — o mais completo: dois concerns (`FinancialEntry`, `VendorNormalization`),
  enum inteiro, constantes de limite (`MIN/MAX_INSTALLMENTS`), validação cross-field (`installment_fields_consistent`),
  scopes compostos (`paid_in_period`).
- **`app/models/goal.rb`** — enum **string** via `KINDS.zip(KINDS).to_h`, `uniqueness` com `scope:`,
  validação de período, class method de defaults (`.new_form_defaults`).
- **`app/models/export.rb`** — delega a resolução de período ao value object `Exports::PeriodRange`
  (a **costura model↔VO**), três enums validados, callbacks (`before_validation`, `after_initialize`).
- **`app/models/concerns/financial_entry.rb`** — concern que injeta `belongs_to :user`, `monetize :amount`
  e os scopes financeiros compartilhados (`for_year`, `for_month`, `in_period`, `chronological`).
- **`app/models/notification.rb`** — conjunto que cresce **sem enum**: `inclusion` contra
  `Notifications::Registry::KINDS`.

## Arquivos desta skill

Leia sob demanda:

- **`reference.md`** — detalhamento: as três formas de enum, os concerns da camada, a regra do limite
  como invariante, a costura model↔value object, associações/scopes/callbacks, padrão de spec,
  anti-padrões e checklist de revisão.
- **`template.rb`** — esqueleto para iniciar um model AR.

## Fluxo sugerido

1. **Criar**: confirme na tabela "Model, value object ou service" que é mesmo um model AR. Parta de
   `template.rb` (ou do exemplar mais próximo), ajuste tabela/enums/associações, ponha o limite de
   negócio como constante + `validates` aqui se houver invariante. Crie o spec no padrão de
   `spec/models/goal_spec.rb` com FactoryBot.
2. **Alterar**: mude enum/validação/associação/scope e **atualize o spec e a factory na mesma mudança**.
3. **Revisar**: rode o checklist de `reference.md` contra o model e o spec.
