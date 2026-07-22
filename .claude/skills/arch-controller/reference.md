# Referência — Controllers

Detalhamento do padrão. Para a visão rápida, veja `SKILL.md`. Para código canônico, leia os
exemplares reais listados no `SKILL.md`.

---

## Actions puras, resposta via concern

Cada action faz três coisas: **pega params**, **chama service/concern** e **responde**. Nada mais. A
`EarningsController` é o alvo do padrão:

```ruby
class EarningsController < ApplicationController
  include RecordRedirect

  before_action :find_earning, only: %i[edit update destroy]

  def create
    result = create_earning_via_creator(:earning)

    if result.success?
      turbo_success(Earnings::CreateView, record: result.earning, record_key: :earning)
    else
      turbo_error(Earnings::CreateView, record: result.earning, record_key: :earning)
    end
  end

  def destroy
    @earning.destroy
    turbo_render_list(Dashboard::EarningsDetailService, Dashboard::EarningsDetailView)
  end

  private

  def find_earning
    @earning = current_user.earnings.find(params[:id])
  end
end
```

`create_earning_via_creator` e `earning_attributes` moram no concern `RecordParams`; a resposta Turbo
mora em `RecordSaveResponse`. O controller não conhece a regra do creator nem monta stream à mão.

---

## As duas famílias de resposta Turbo

### Família 1 — `RecordSaveResponse` (render parcial + totais)

Para salvar/editar/excluir um registro e re-renderizar a lista com os totais do dashboard.

- `turbo_success(view_class, record:, record_key:, detail_service: nil, **extra)` — renderiza a view
  Phlex do registro + `totals` (via `Dashboard::StatsService`); opcionalmente injeta `detail`.
- `turbo_error(view_class, record:, record_key:, **extra)` — `flash.now[:alert]` + render com
  `status: :unprocessable_content`.
- `turbo_render_list(detail_service, detail_view)` — usado no `destroy`: recalcula detail + totais e
  renderiza `Dashboard::DeleteRefreshView`.

### Família 2 — `ModalRefreshResponse` (fecha modal + morphing refresh)

Para a família de veículo/goals, onde a ação vive num modal e o efeito é atualizar a página inteira via
Turbo morphing.

- `respond_with_modal_refresh(html_redirect:)` — `turbo_stream.update('modal', '')` +
  `turbo_stream.refresh`; `format.html` cai em `redirect_to html_redirect`.
- `respond_with_refresh(html_redirect:)` — só o refresh (usado no `destroy`).

```ruby
def create
  @maintenance = current_user.vehicle.maintenances.new(maintenance_params).apply_catalog_defaults

  if @maintenance.save
    flash[:notice] = t('maintenances.flash.created')
    respond_with_modal_refresh(html_redirect: vehicle_path)
  else
    flash.now[:alert] = @maintenance.errors.full_messages.to_sentence
    render Maintenances::FormView.new(maintenance: @maintenance), status: :unprocessable_content
  end
end
```

**Nunca** monte `render turbo_stream: [turbo_stream.update(...), ...]` dentro de uma action — isso é a
implementação do concern, não da action.

---

## Guards e params via concern

- **Guard `before_action` compartilhado** entre controllers da mesma família vira concern:
  ```ruby
  module RequiresVehicle
    extend ActiveSupport::Concern
    included { before_action :require_vehicle }

    private

    def require_vehicle
      redirect_to vehicle_path unless current_user.vehicle
    end
  end
  ```
  No controller: `include RequiresVehicle`.
- **Strong-params e orquestração de creator** ficam em `RecordParams` (`earning_attributes(scope_key)`,
  `create_earning_via_creator`). **Redirect de novo registro** em `RecordRedirect`. O controller inclui
  o concern e chama o método — não redefine strong-params espalhados.

---

## Isolamento de usuário e o finder residual

Toda busca/criação é **scoped pelo usuário**: `current_user.earnings.find(params[:id])`,
`current_user.vehicle.maintenances.new(...)`. Nunca `Earning.find` global — isso vazaria registro de
outro dono.

O **único método privado** que sobra numa action bem enxuta é o **finder trivial** `find_x`, usado num
`before_action`. Ele pode tratar ausência:

```ruby
def find_maintenance
  @maintenance = current_user.vehicle.maintenances.find(params[:id])
rescue ActiveRecord::RecordNotFound
  head :not_found
end
```

Strong-params inline (`maintenance_params`) ainda aparecem em controllers não totalmente extraídos; o
alvo é movê-los para um concern no estilo `RecordParams`. Qualquer outro método privado (cálculo,
montagem de resposta, orquestração) é sinal de que a lógica deveria estar num service ou concern.

---

## Padrão de request spec

O controller é exercitado por request spec em `spec/requests/<recurso>_spec.rb`: autentica, dispara a
action e afirma **status**, **redirect**, **efeito no banco** e, quando Turbo, o `Content-Type`/stream.
Isolamento de usuário (registro de outro dono → `not_found`) é caso obrigatório. Regras gerais (sem
`let!`, AAA com linha vazia, sem comentários, cobertura 100%) em **arch-spec**.

---

## Anti-padrões

- Lógica de negócio, cálculo ou persistência multi-model dentro da action — vai para service.
- `render turbo_stream: [...]` montado à mão numa action — vive no concern de resposta.
- Método privado que não seja o finder trivial (ou strong-params ainda-não-extraído).
- `Model.find(params[:id])` global em vez de `current_user.<assoc>.find` — vaza dado entre usuários.
- Repetir o mesmo `before_action` guard em vários controllers em vez de extrair concern.
- Duplicar a resposta Turbo em cada action em vez de usar `turbo_success`/`respond_with_modal_refresh`.
- Escrever comentário `#` no arquivo `.rb`; ou entregar o controller **sem** request spec.

---

## Checklist de revisão

**Controller**

- [ ] `< ApplicationController`; actions pegam params → chamam service/concern → respondem.
- [ ] Zero lógica de negócio; nenhum `render turbo_stream: [...]` inline.
- [ ] Resposta via `RecordSaveResponse` (salvar + totais) ou `ModalRefreshResponse` (modal + refresh).
- [ ] Guard compartilhado e strong-params/orquestração em **concern**, não repetidos.
- [ ] Único método privado é o finder `find_x` scoped por `current_user` (strong-params só se não extraído).
- [ ] Toda busca/criação isolada por `current_user.<assoc>`.
- [ ] Erro renderiza com `status: :unprocessable_content`.

**Spec**

- [ ] Request spec em `spec/requests/`, cobrindo status/redirect/turbo e efeito no banco.
- [ ] Isolamento de usuário coberto (registro de outro dono → `not_found`).
- [ ] Segue **arch-spec** (sem `let!`, AAA com linha vazia, sem comentários, cobertura 100%).
