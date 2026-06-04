# Inline Validation — Formulário de Cadastro

**Data:** 2026-06-04
**Status:** Aprovado

## Problema

O formulário de cadastro exibe todos os erros num banner genérico no topo da página após o submit. O resultado são mensagens desconexas dos campos que as causaram e sem feedback em tempo real.

## Objetivo

Validação inline por campo: erros aparecem abaixo do campo afetado, em tempo real após o primeiro blur, com estado visual claro (borda + fundo + ícone). O banner de erros é removido.

## Decisões de design

| Decisão | Escolha |
|---|---|
| Estilo de erro | Borda vermelha + fundo rosado + ícone ✕ + texto abaixo |
| Estado válido | Borda verde + fundo verde-claro + ícone ✓ |
| Trigger | Blur (primeira vez) → input (após ter tocado) |
| Campos de senha | Só borda + fundo (sem ✕/✓ — slot direito ocupado pelo toggle de visibilidade) |
| Domínio de e-mail | Validado só no servidor (submit → 422 → erro inline no campo) |

## Arquitetura

### Stimulus controller — `registration-form`

Único controller no elemento `<form>`. Responsável por toda a validação client-side.

**Targets:**
- `nameField` / `nameError`
- `emailField` / `emailError`
- `passwordField` / `passwordError`
- `confirmationField` / `confirmationError`

**Trigger:**
Cada input recebe `blur->registration-form#validate` e `input->registration-form#validate`.
O controller mantém um `Set` interno de campos tocados. O handler de `input` só valida se o campo já passou por pelo menos um `blur`.

**Validações client-side:**

| Campo | Regras |
|---|---|
| `name` | não vazio |
| `email_address` | não vazio + regex de formato básico |
| `password` | não vazio + mínimo 8 caracteres |
| `password_confirmation` | igual ao valor atual de `password` |

Quando `password` muda, a confirmação é re-validada automaticamente se já foi tocada.

**Validações exclusivas do servidor (após submit):**
- Domínio de e-mail não permitido
- E-mail já em uso

**Estados visuais** (via classes Tailwind aplicadas pelo controller):

| Estado | Classes no `<input>` |
|---|---|
| Neutro | `border-slate-200 bg-white` |
| Erro | `border-red-400 bg-red-50` |
| Válido | `border-green-500 bg-green-50` |

O ícone esquerdo de cada campo herda a cor do estado via classe no elemento pai.

### View — `Registrations::NewView`

**Removido:** `errors_block` (banner genérico no topo).

**Adicionado por campo:**
- `data-registration-form-target="xField"` no `<input>`
- `data-registration-form-target="xError"` no `<p>` de erro abaixo do campo
- `data-action="blur->registration-form#validate input->registration-form#validate"` no `<input>`
- `data-field="x"` no `<input>` para identificação interna do controller

**Erros do servidor (422):** a view pré-popula o elemento de erro com `@user.errors[:attribute].first` e aplica as classes de estado de erro diretamente no `<input>` e no elemento pai do ícone. O Stimulus detecta o estado pré-aplicado e não interfere até o próximo evento do usuário.

### Arquivo do controller

`app/javascript/controllers/registration_form_controller.js`

## Testes

**Request spec (`registrations_spec.rb`):**
- Erro de domínio de e-mail aparece no HTML próximo ao campo `email_address` (não num banner genérico)
- Erro de confirmação de senha aparece próximo ao campo `password_confirmation`
- Nenhum `errors_block` genérico presente no HTML de resposta 422

**Sem testes de Stimulus:** comportamento client-side não é coberto por RSpec. O fluxo de submit cobre o caminho servidor → erro inline.

## Arquivos afetados

| Arquivo | Mudança |
|---|---|
| `app/javascript/controllers/registration_form_controller.js` | Novo |
| `app/views/registrations/new_view.rb` | Remove `errors_block`, adiciona targets/actions/error elements |
| `spec/requests/registrations_spec.rb` | Novos exemplos para erros inline |
