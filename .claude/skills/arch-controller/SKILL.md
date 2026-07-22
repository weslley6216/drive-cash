---
name: arch-controller
description: Use when creating, altering, or reviewing a Rails controller in DriveCash — a class under app/controllers/ inheriting from ApplicationController that holds only actions and no business logic. Use for actions that call a service and respond through the Turbo concerns (RecordSaveResponse's turbo_success/turbo_error/turbo_render_list, or ModalRefreshResponse's respond_with_modal_refresh), shared before_action guards extracted as concerns (RequiresVehicle), strong-params and finders scoped by current_user, and rendering Phlex views. NOT for business logic (that is arch-service) or view markup (arch-component). Takes precedence over divergent legacy code.
---

# Skill: Controllers

## Propósito

Referência de como o DriveCash modela a camada de **controller**. Use ao **criar**, **alterar** ou
**revisar** um controller (e seu request spec) para garantir aderência ao padrão.

Um controller **só tem actions**: cada action pega params, chama um **service** (ou concern de
orquestração) e **responde** por um concern padronizado — nunca lógica de negócio, nunca
`render turbo_stream: [...]` montado à mão. A resposta Turbo, os strong-params, os guards
`before_action` compartilhados e a orquestração pós-confirm vivem em **concerns**.

## Quando usar

- Vou criar/alterar/revisar um controller ou seu request spec.
- Preciso responder a um form via Turbo (salvar registro, fechar modal + refresh).
- Preciso de um guard `before_action` compartilhado ou de strong-params reutilizados.

## O que vai no controller × o que sai (a decisão que erra fácil)

| Se… | Vai para | Onde |
|-----|----------|------|
| Pega params, chama service, responde | **Action** | o próprio controller |
| Resposta Turbo padronizada | **Concern de resposta** | `RecordSaveResponse` / `ModalRefreshResponse` |
| Strong-params / orquestração de creator | **Concern de params** | `RecordParams`, `RecordRedirect` |
| Guard `before_action` compartilhado entre controllers | **Concern de guard** | `RequiresVehicle` |
| Regra de negócio, cálculo, persistência multi-model | **Service** | `app/services/<domínio>/` → **arch-service** |
| Markup, moeda, cor, i18n visível | **Component Phlex** | `app/components/` → **arch-component** |

## Convenções essenciais

| Aspecto | Regra |
|---------|-------|
| Base | `class XController < ApplicationController` (que já inclui `Authentication`, `DashboardContext`, `RecordParams`, `RecordSaveResponse`, `ModalRefreshResponse`) |
| Action | pega params → chama service/concern → responde/renderiza; **sem** lógica de negócio |
| Nunca inline | **jamais** `render turbo_stream: [...]` à mão numa action — vive no concern de resposta |
| Resposta — família 1 | `RecordSaveResponse`: `turbo_success`/`turbo_error` (render de view Phlex + totais) e `turbo_render_list` (delete + refresh de lista) |
| Resposta — família 2 | `ModalRefreshResponse`: `respond_with_modal_refresh(html_redirect:)` (fecha modal + refresh via morphing) e `respond_with_refresh` |
| Render Phlex | `render SomeView.new(...)`; erro com `status: :unprocessable_content` |
| Guard compartilhado | `before_action` extraído para concern (`include RequiresVehicle` → `require_vehicle`) |
| Métodos privados | só o **finder trivial** `find_x` (via `current_user.assoc.find`) — e strong-params quando ainda não extraídos; **nenhum** método de negócio |
| Isolamento de usuário | sempre `current_user.<assoc>.find/new` — nunca `Model.find` global |
| `RecordNotFound` | finder pode `rescue ActiveRecord::RecordNotFound` → `head :not_found` |
| Spec | request spec em `spec/requests/`, exercita status/redirect/turbo; regras gerais em **arch-spec** |

## Exemplares reais (canônicos, atuais)

Leia o código real destes antes de escrever um novo:

- **`app/controllers/earnings_controller.rb`** — o alvo do padrão: actions puras, `create` via
  `create_earning_via_creator` + `turbo_success`/`turbo_error`, `destroy` via `turbo_render_list`;
  único método privado é o finder `find_earning`.
- **`app/controllers/maintenances_controller.rb`** — a família modal: `include RequiresVehicle`,
  `respond_with_modal_refresh(html_redirect: vehicle_path)` no sucesso, render de `FormView` com
  `status: :unprocessable_content` no erro; finder com `rescue → head :not_found`.
- **`app/controllers/concerns/record_save_response.rb`** — família 1 de resposta Turbo.
- **`app/controllers/concerns/modal_refresh_response.rb`** — família 2 (modal + morphing refresh).
- **`app/controllers/concerns/record_params.rb`** / **`requires_vehicle.rb`** — strong-params/orquestração
  e guard compartilhado extraídos.

## Arquivos desta skill

Leia sob demanda:

- **`reference.md`** — detalhamento: as duas famílias de resposta Turbo, guards/params via concern, o
  finder scoped por usuário, o que fica de resíduo privado, padrão de request spec, anti-padrões e checklist.
- **`template.rb`** — esqueleto de um resource controller usando a família `RecordSaveResponse`.

## Fluxo sugerido

1. **Criar**: decida a família de resposta (salvar-com-totais vs. modal-refresh). Parta de `template.rb`
   (ou de `earnings_controller.rb`/`maintenances_controller.rb`). Extraia guard/params compartilhados para
   concern. Crie o request spec.
2. **Alterar**: mude a action e **atualize o spec na mesma mudança**; se surgir lógica, mova para service.
3. **Revisar**: rode o checklist de `reference.md` contra o controller e o spec.
