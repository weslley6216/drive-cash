---
name: arch-spec
description: Use when writing or reviewing any RSpec spec in DriveCash — the shared conventions every layer's spec follows. Use for the no-let! rule, AAA with a blank line between phases, banning allow_any_instance_of/expect_any_instance_of, the positive-pair requirement for negative-only tests, FactoryBot vs .new by layer, the shared setup (SimpleCov 100%, shoulda-matchers, DatabaseCleaner, time helpers, login_as, view_context), and the spec type and directory map. Layer-specific spec shapes live in arch-model, arch-service, arch-controller, arch-component, arch-presenter, arch-value-object. Takes precedence over divergent legacy code.
---

# Skill: Specs (RSpec — base compartilhada)

## Propósito

Referência das **convenções de spec compartilhadas** por todas as camadas do DriveCash. Use ao
**escrever** ou **revisar** qualquer spec. Cada skill de camada traz o *shape* da sua spec e referencia
esta para as regras gerais.

Testes são RSpec + FactoryBot + SimpleCov com **cobertura 100% obrigatória**. As regras abaixo valem para
todo spec, de qualquer camada.

## Quando usar

- Vou escrever/revisar um spec de qualquer camada (model, service, controller, component, presenter, VO).
- Estou em dúvida sobre `let` vs `before`, AAA, mock, ou factory vs `.new`.
- Preciso saber o setup disponível (helpers, matchers, time travel, login).

## As regras da casa (o que erra fácil)

| Regra | Detalhe |
|-------|---------|
| **Sem `let!`** | usar `let` + referência explícita, `before { create(...) }` ou `create` dentro do `it` |
| **AAA com linha vazia** | linha em branco entre Arrange/Act/Assert quando as três fases estão no `it`; se arrange/act estão em `let`, o `it` só tem o Assert |
| **Nunca comentários** | nada de `# Arrange`, nem qualquer outro comentário no spec |
| **Sem `*_any_instance_of`** | proibido `allow_any_instance_of`/`expect_any_instance_of`; mockar classe/instância específica (`allow(MyClass).to receive(...)`) ou testar o comportamento resultante |
| **Sem referência a ACs** | o nome do exemplo descreve o comportamento e faz sentido sozinho |
| **Teste só-negativo exige par positivo** | um `not_to include/match/have_key` sem exemplo positivo de estado oposto passa pra sempre — não escrever. Exceções (têm par de estado): `not_to be_valid`, isolamento entre usuários, filtros/scopes, elementos condicionais |
| **Sem var de bloco de 1 letra** | `|record|` não `|r|`; usar o nome do domínio |
| **Construção por camada** | **Value object** usa `.new(...)` (sem factory); **model/service/controller/component** usam FactoryBot (`build`/`create`) |

## Setup disponível (spec/support + helpers)

| Ferramenta | Uso |
|------------|-----|
| **SimpleCov** | `minimum_coverage 100` — toda linha nova precisa de spec (bloqueia abaixo de 100%) |
| **FactoryBot** | `FactoryBot::Syntax::Methods` incluído — `build(:x)`/`create(:x)` diretos; factories em `spec/factories/<plural>.rb` |
| **shoulda-matchers** | `validate_presence_of`, `define_enum_for`, etc. (rspec + rails) |
| **DatabaseCleaner** | transação por exemplo; truncation no boot e em `js: true` |
| **Time helpers** | `ActiveSupport::Testing::TimeHelpers` — `travel_to`, `freeze_time` |
| **`login_as(user)`** | `type: :request` — autentica via `POST session_path` (senha `password123`) |
| **`view_context`** | `type: :component` — renderiza Phlex via `view_context.render(...)` |
| **`verify_partial_doubles`** | ligado — mock precisa bater com a assinatura real do método |

## Tipo e diretório por camada

| Camada | Diretório | `type:` | Constrói com | Shape em |
|--------|-----------|---------|--------------|----------|
| Model | `spec/models/` | `:model` | FactoryBot | **arch-model** |
| Value object | `spec/models/<domínio>/` | — | `.new(...)` | **arch-value-object** |
| Service | `spec/services/<domínio>/` | — | FactoryBot + banco | **arch-service** |
| Controller | `spec/requests/` | `:request` | FactoryBot + `login_as` | **arch-controller** |
| Component/View | `spec/components/` | `:component` | `view_context.render` | **arch-component** |
| Presenter | `spec/presenters/<domínio>/` | — | payload cru / FactoryBot | **arch-presenter** |

## Exemplares reais (canônicos, atuais)

- **`spec/models/goal_spec.rb`** — model: shoulda-matchers + erros por campo, AAA com linha vazia.
- **`spec/services/earnings/creator_spec.rb`** — service: `describe '.call'`, sucesso/falha/isolamento de usuário.
- **`spec/components/stat_card_component_spec.rb`** — component: `view_context.render` + design tokens.
- **`spec/presenters/dashboard/insights/presenters_spec.rb`** — presenter: `.present` + completude produtor/presenter.
- **`spec/models/expenses/installment_plan_spec.rb`** — value object: `.new` + fronteiras de invariante.

## Arquivos desta skill

- **`reference.md`** — detalhamento de cada regra, o porquê do par positivo, exemplos certo/errado e checklist.
- **`template.rb`** — esqueleto mínimo de um spec no padrão da casa.

## Fluxo sugerido

1. **Escrever**: use o *shape* da skill de camada + estas regras gerais. Parta de `template.rb` ou do exemplar da camada.
2. **Revisar**: rode o checklist de `reference.md`; confirme cobertura 100% e ausência de `let!`/comentários/`*_any_instance_of`.
