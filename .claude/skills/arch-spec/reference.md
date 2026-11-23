# Referência — Specs (base compartilhada)

Detalhamento das regras. Para a visão rápida, veja `SKILL.md`. Para o *shape* de cada camada, veja a
skill de camada correspondente (**arch-model**, **arch-service**, etc.).

---

## Sem `let!`

`let!` cria dado implícito e obscurece o Arrange. Use `let` (lazy, referenciado explicitamente),
`before { create(...) }` ou `create` dentro do `it`.

```ruby
# ❌ errado
let!(:earning) { create(:earning, user: user) }

# ✅ certo — referência explícita
let(:earning) { create(:earning, user: user) }

it 'lists the earning' do
  earning

  expect(described_class.call(user)).to include(earning)
end
```

---

## AAA com linha vazia

Quando as três fases estão no `it`, separe Arrange / Act / Assert por **linha em branco** — nunca por
comentário. Quando Arrange/Act já estão em `let`, o `it` tem **só o Assert**.

```ruby
it 'creates an earning owned by the user' do
  result = described_class.call(valid_params, user: user)   # Act (arrange no let)

  expect(result.earning.user).to eq(user)                    # Assert
end

it 'rejects period_end before period_start' do
  goal = build(:goal, period_start: Date.new(2026, 6, 10), period_end: Date.new(2026, 6, 1))

  goal.valid?

  expect(goal.errors[:period_end]).to be_present
end
```

---

## Sem `def` em arquivo de spec

O spec é a documentação da funcionalidade: lê-se de cima a baixo sem saltar para um helper. Nenhum
`def`/`define_method` em `*_spec.rb` — nem helper de render, nem builder de dado, nem componente-host
com `def view_template`.

- **Arrange literal**: `create(...)`/`build_stubbed(...)` com os valores no próprio `it`, ou `let`/`before`.
- **Variação de cenário**: `context` com `let` sobrescrito (`let(:window) { twelve_months.merge(count: 0) }`), não método parametrizado.
- **Slot de componente**: o bloco vai direto no `render` — `view_context.render(described_class.new) { |screen| screen.with_content { screen.p { 'Corpo' } } }`.
- **Leitura da página** inline no Assert; quando a expressão cresce, vira uma linha de Act (`html = view_context.render(...)`) antes do `expect`.
- **Vocabulário compartilhado de verdade** (login, matcher customizado) mora em `spec/support/`, com nome do domínio e **sem `expect` dentro**.

Guardado por `spec/conventions/helper_discipline_spec.rb` (portado do Zubio).

---

## Sem `allow_any_instance_of` / `expect_any_instance_of`

Mock frouxo esconde qual objeto colabora e quebra com `verify_partial_doubles`. Mocke a **classe ou
instância específica**, ou teste o comportamento resultante.

```ruby
# ❌ errado
allow_any_instance_of(Groq::Client).to receive(:chat).and_return(...)

# ✅ certo — classe específica
allow(Groq::Client).to receive(:new).and_return(client)
allow(client).to receive(:chat).and_return(...)
```

---

## Teste só-negativo exige par positivo discriminante

Um exemplo cuja única asserção é negativa (`not_to include/match/have_key`) **sem** um exemplo positivo
de estado oposto na mesma área verifica ausência permanente — passa pra sempre e não pega regressão. Não
escrever; remover se existir.

```ruby
# ✅ par discriminante
it 'renders as link when href is provided' do
  html = view_context.render(described_class.new(**attrs, href: '/test'))

  expect(html).to include('<a')
end

it 'renders as div when href is absent' do
  html = view_context.render(described_class.new(**attrs))

  expect(html).not_to include('<a')
end
```

Exceções legítimas (têm estado-par implícito): `not_to be_valid`, isolamento entre usuários, filtros/
scopes, elementos condicionais. Detalhe completo: `rules/03 - Regras de Testes.md` no vault.

---

## Construção por camada: FactoryBot vs `.new`

- **Value object** é objeto Ruby puro sem banco → constrói com `.new(...)`, **sem factory**.
- **Model, service, controller, component** → **FactoryBot** (`build` quando não precisa persistir,
  `create` quando precisa). Factories em `spec/factories/<plural>.rb` com o mínimo de atributos válidos.

O `build` evita ir ao banco à toa (validações e métodos de instância não precisam de `create`); use
`create` só quando o teste depende de persistência (scopes, associação carregada, `reload`).

---

## Setup compartilhado (o que já está ligado)

- **SimpleCov** com `minimum_coverage 100` (filtra `channels`/`jobs`): cobertura abaixo de 100% falha a suite.
- **`verify_partial_doubles = true`**: todo mock precisa bater com a assinatura real.
- **FactoryBot::Syntax::Methods**, **shoulda-matchers** (rspec+rails), **DatabaseCleaner** (transação por
  exemplo), **TimeHelpers** (`travel_to`/`freeze_time`).
- **`login_as(user)`** em `type: :request`; **`view_context`** em `type: :component`.
- **`spec/support/external_http.rb`**: WebMock bloqueia rede externa e o VCR reprova HTTP fora de cassete com `External HTTP attempted:`; o contrato real do adapter Groq vive em `vcr: { cassette_name: 'llm/groq/…' }` (regravação com `VCR_RECORD=1`), casos sintéticos usam doubles do Faraday.

---

## Anti-padrões

- `let!`; comentário de qualquer tipo no spec; nome de exemplo referenciando AC.
- `allow_any_instance_of`/`expect_any_instance_of`.
- `def`/`define_method` em arquivo de spec; `expect` dentro de `spec/support/`.
- Teste só-negativo sem par positivo discriminante.
- Variável de bloco de uma letra (`|r|`, `|g|`, `|i|`).
- Factory para value object; `.new` cru para model/service.
- Deixar linha nova sem cobertura (quebra SimpleCov 100%).

---

## Checklist de revisão

- [ ] Sem `let!`; Arrange via `let`/`before`/`create` no `it`.
- [ ] AAA com **linha vazia** entre fases quando as três estão no `it`; sem comentários.
- [ ] Sem `allow_any_instance_of`/`expect_any_instance_of`; mock de classe/instância específica.
- [ ] Sem `def` no arquivo de spec; helper compartilhado só em `spec/support/` e sem `expect`.
- [ ] Nome do exemplo descreve comportamento, sem referência a AC.
- [ ] Todo teste só-negativo tem par positivo discriminante (ou é exceção legítima).
- [ ] Value object com `.new`; demais camadas com FactoryBot; factory mínima.
- [ ] Sem variável de bloco de uma letra.
- [ ] Cobertura 100% mantida; *shape* específico conforme a skill da camada.
