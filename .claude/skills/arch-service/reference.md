# Referência — Services

Detalhamento do padrão. Para a visão rápida, veja `SKILL.md`. Para código canônico, leia os
exemplares reais listados no `SKILL.md`.

---

## O entry point `self.call`

O service expõe um método de classe `self.call` que instancia e chama — quem consome nunca faz `new`
direto. `initialize` só guarda os inputs; `call` orquestra.

```ruby
module Earnings
  class Creator
    Result = Data.define(:success?, :earning)

    def self.call(earning_params, user:)
      new(earning_params, user: user).call
    end

    def initialize(earning_params, user:)
      @earning_params = earning_params.to_h.stringify_keys.except('user_id')
      @user = user
    end

    def call
      earning = @user.earnings.new(@earning_params)
      earning.save ? Result.new(success?: true, earning: earning) : Result.new(success?: false, earning: earning)
    end
  end
end
```

Um calculador puro (sem efeito colateral) pode expor um método de consulta em vez de `call`
(`VendorEfficiency#cheapest`), mas mantém `initialize` por keyword args e o mesmo formato de retorno.

---

## Payload semântico, não apresentação

O service devolve **estrutura + dado cru**: um `Data.define` ou um hash com números, chaves de enum,
`Date`. **Nunca** devolve string formatada, cor, token ou i18n visível.

```ruby
Comparison = Data.define(:winner, :winner_kml, :runner_up, :runner_up_kml, :savings)
# winner_kml é BigDecimal, savings é Integer — cru. A formatação (km/l, R$) é do component.
```

Exceção estreita: **rótulo i18n 1:1** de uma chave de enum (`I18n.t("platforms.#{platform}")`) **pode**
ficar no service, porque é tradução direta da chave, não decisão de apresentação. Cor, símbolo de moeda
e `number_to_currency` **nunca**.

---

## Cálculo nunca convive com formatação

Se um service calcula domínio **e** você sentiu vontade de formatar no mesmo arquivo, extraia o cálculo
para um **calculador puro** (`Refuelings::VendorEfficiency`, `Dashboard::EarningsCalculator`,
`Dashboard::PercentChange`). O calculador devolve dado cru; a orquestração/persistência fica no service
que o chama; a formatação fica no component. Um arquivo, uma responsabilidade.

Thresholds do **próprio cálculo** (`MIN_DISTINCT_VENDORS = 3`) são constantes do calculador — ok. Mas
**limite de negócio** que é invariante de registro (`Expense::MAX_INSTALLMENTS`) mora no **model**; o
service referencia, nunca redefine.

---

## Variação que cresce → registry (OCP)

Conjunto que cresce (ferramenta de chat, filtro de histórico, tipo de export, gerador) despacha por um
**registry** — hash ou array **congelado** de `Data` — resolvido por `.fetch`/`.find`. Adicionar uma
variante = uma entrada declarativa + seus colaboradores; nunca `case/when`/`if-elsif` espalhado.

```ruby
FILTERS = {
  'all'      => Filter.new(earnings: true,  expense_scope: ->(user, year, month) { user.expenses.paid_in_period(year, month) }),
  'earnings' => Filter.new(earnings: true,  expense_scope: nil),
  'expenses' => Filter.new(earnings: false, expense_scope: ->(user, year, month) { user.expenses.paid_in_period(year, month) })
}.freeze

def filter_config = FILTERS.fetch(filter, FILTERS.fetch('all'))
```

**OCP não revoga SRP**: o registry **referencia** colaboradores (reader, persister, presenter) — não os
contém. Veja `Ai::Tools::Registry`: cada `Tool` aponta para `persister:`/`summary_presenter:`, que são
classes separadas. Use `.fetch` com default explícito, não `[]` silencioso.

---

## Isolamento de usuário

Service que persiste opera **sempre** pelo scope da associação (`@user.earnings.new(...)`), e **descarta
`user_id`** vindo no payload (`params.except('user_id')`). Assim um `user_id` forjado no corpo não cria
registro para outro dono. O spec cobre isso explicitamente.

---

## Job = casca fina sobre o service

Job (`app/jobs/`) é casca fina sobre Solid Queue: acha o registro, muda status, **delega ao service** a
lógica, trata `rescue`. Zero regra de domínio no job.

```ruby
class ExportJob < ApplicationJob
  queue_as :default

  def perform(export_id)
    export = Export.find(export_id)
    export.update!(status: :processing)

    payload = Exports::Builder.call(export: export)
    file = Exports::Registry.for(export.format).call(payload: payload)
    export.file.attach(io: file.io, filename: file.filename, content_type: file.content_type)
    export.update!(status: :done)
  rescue StandardError
    export&.update(status: :failed)
    raise
  end
end
```

---

## Padrão de spec (com banco e FactoryBot)

O service tem spec em `spec/services/<domínio>/<nome>_spec.rb`. Usa FactoryBot + banco (diferente do
value object, que é `.new` puro). Estrutura por `describe '.call'`, afirmando sobre o **payload** e o
**estado persistido**.

```ruby
RSpec.describe Earnings::Creator do
  let(:user) { create(:user) }

  describe '.call' do
    let(:valid_params) { { date: '2026-05-22', amount: '245.00', platform: 'uber', trips_count: 7 } }

    it 'creates an earning owned by the user' do
      result = described_class.call(valid_params, user: user)

      expect(result.success?).to be(true)
      expect(result.earning.user).to eq(user)
    end

    it 'ignores user_id forged inside the attributes payload' do
      other = create(:user)

      result = described_class.call(valid_params.merge(user_id: other.id), user: user)

      expect(result.earning.user).to eq(user)
    end
  end
end
```

Cobrir: caminho de sucesso (payload + persistência), caminho de falha (`success? == false`, erros
presentes), isolamento de usuário, completude do registry quando houver
(`expect(Registry::TOOLS.map(&:name)).to include(...)`). Regras gerais (sem `let!`, AAA com linha vazia,
sem `allow_any_instance_of`, sem comentários, cobertura 100%) em **arch-spec**.

---

## Anti-padrões

- Consumidor chamando `Service.new(...).call` em vez do entry point `self.call`.
- Devolver apresentação do service: `number_to_currency`, cor, token, string de UI.
- Cálculo de domínio **e** formatação no mesmo arquivo — extraia calculador puro.
- Despachar variação que cresce com `case/when`/`if-elsif` em vez de registry congelado.
- Registry que **contém** a lógica do colaborador em vez de referenciá-lo (fere SRP).
- Redefinir limite de negócio (`MAX_*`) no service — ele é invariante do model.
- Confiar em `user_id` do payload em vez de scoping por `@user.associação`.
- Regra de domínio no **job** em vez de delegar ao service.
- Namespace no singular (`module Earning`) — sempre plural (`module Earnings`).
- Escrever comentário `#` no arquivo `.rb`; ou entregar o service **sem** o spec.

---

## Checklist de revisão

**Service**

- [ ] `module <Domínio-plural>`, arquivo em `app/services/<domínio>/`.
- [ ] Entry point `self.call` delegando a `new(...).call`; `initialize` só guarda.
- [ ] Retorno é **payload semântico** (`Data`/hash de dado cru), sem apresentação.
- [ ] Cálculo separado de formatação; cálculo puro extraído para calculador quando houver.
- [ ] Variação que cresce via **registry** (`.fetch`/`.find`), não `case/when`; registry referencia colaboradores.
- [ ] Limite de negócio referenciado do model; só thresholds do próprio cálculo como constante local.
- [ ] Persistência scoped por `@user.associação`, descartando `user_id` forjado.
- [ ] Job (se houver) é casca fina delegando ao service.

**Spec**

- [ ] Em `spec/services/<domínio>/<nome>_spec.rb`, FactoryBot + banco, `describe '.call'`.
- [ ] Sucesso, falha, isolamento de usuário e completude de registry cobertos.
- [ ] Segue **arch-spec** (sem `let!`, AAA com linha vazia, sem comentários, cobertura 100%).
