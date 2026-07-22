---
name: execute
description: Fase 3 do fluxo — execução. Implementa seguindo o plano à risca, com TDD.
argument-hint: NN
disable-model-invocation: true
---

# Fase 3 — Execução

Argumento recebido: $ARGUMENTS

## Pré-condições

1. **Derivar slug e verificar plano pronto para execução:**
   ```bash
   TASK_FILE=$(find ~/Obsidian/DriveCash/tasks -name "${ARGUMENTS}-*.md" | head -1)
   TASK_SLUG=$(basename "$TASK_FILE" .md)
   PLAN="/home/rebase/Obsidian/DriveCash/work/plans/$TASK_SLUG.md"
   grep "^status:" "$PLAN"
   ```
   Se o arquivo não existir ou o status não for `pronto_para_execucao`, parar e apontar `/plan $ARGUMENTS`.

2. **Working directory:** `/home/rebase/workspace/DriveCash`

3. **Branch:**
   ```bash
   git checkout main && git pull
   git checkout -b feature/$TASK_SLUG
   ```
   Se o card exige migration separada, criar `migrate/task-$ARGUMENTS-...` primeiro e ramificar `feature/` a partir dela.

## Execução

4. **Carregar plano:** `Read` em `$PLAN`. Não copiar conteúdo no chat — referenciar.

5. **Invocar skill `superpowers:executing-plans`** passando o caminho do plano.

6. **TDD obrigatório** — invocar `superpowers:test-driven-development`:
   - Spec primeiro
   - Watch fail (rodar suite)
   - Implementação mínima
   - Watch pass
   - Refatorar se necessário

7. **Padrão AAA nos specs** — linha em branco entre cada seção Arrange / Act / Assert.

8. **Todos os comandos via Docker:**
   ```bash
   rtk docker compose run --rm app bundle exec rspec spec/path/to/spec.rb
   rtk docker compose run --rm app bundle exec rspec  # suite completa
   ```
   SimpleCov deve permanecer em 100% após cada commit.

9. **Comandos do plano:** copiar exatamente como escrito. **Não adaptar, não adicionar campos.**

10. **Commits:**
    - Por classe (impl + spec juntos)
    - Conventional commits: `feat:`, `fix:`, `refactor:`, `style:`, `test:`
    - **Sem Co-Authored-By** (regra do usuário)
    - **Stagear por nome explícito** — nunca `git add .`
    - O hook pre-commit roda `rubocop -A` automaticamente — não rodar manualmente
    - **Exibir branch atual antes de cada commit**

11. **Atualização de Estado:** Sempre que um AC do plano for concluído com specs verdes, **atualizar o arquivo Markdown do Plano** marcando o checklist correspondente para `[x]`.

## Política de desvio

O escopo foi fechado no `/discovery` e no `/plan` — **proibido usar `AskUserQuestion` para escopo nesta fase.** Quando o plano não cobre algo:

- **Desvio tático** (nome, detalhe de spec, ajuste de implementação que não muda AC): decidir sozinho, implementar e registrar em `## Desvios do plano` no arquivo do plano — uma linha com o que mudou e por quê.
- **Gap de escopo** (AC inviável como escrito, premissa do plano errada, comportamento não definido): parar. Gravar seção `## Gap de escopo` no plano descrevendo o buraco, setar frontmatter `status: bloqueado_replan` e encerrar com o bloco de replan abaixo. Quem resolve é o `/plan $ARGUMENTS`, re-interrogando o usuário.

Na dúvida entre tático e gap: se a decisão seria visível pro usuário final ou muda um AC, é gap.

## Verificação periódica

A cada ~30min ou ~30 turnos, perguntar ao usuário pra rodar `/context`. Se >70%, parar e fazer handoff intermediário (salvar progresso no plano em formato checklist).

## Gate de débito técnico — [[11 - Checklist de Revisão]]

Antes de encerrar (specs verdes + ACs prontos), revise o **código escrito** nesta fase contra os princípios de nível de linha, de `~/Obsidian/DriveCash/rules/11 - Checklist de Revisão.md`:

**Legibilidade · Código Morto · N+1 · Segurança · Phlex · Rails Way · Testabilidade**

- Rode cada princípio sobre o diff: nome que mente ou abreviado, param/método sem uso, query em loop, query sem escopo de usuário, componente que toca o banco, controller com lógica, asserção vaga.
- **Violação não resolvida → bloqueia.** Não encerre a execução. Apresente os achados ao usuário e aguarde — corrigir aqui é mais barato que no PR.
- **Válvula registrada:** trade-off aceito conscientemente vai pra seção `## Arquitetura & Caminhos Descartados (ADR)` do discovery (`work/discovery/<slug>.md`) como **Dívida aceita**.
- Zero débito técnico novo: a fase não encerra com violação não resolvida e não registrada.

## ENCERRAMENTO OBRIGATÓRIO

Quando todos os ACs do plano estiverem implementados E specs verdes, **antes** de exibir o bloco:

1. Gravar `## Handoff de execução` no arquivo do plano: branch, nº de commits, resultado da suite, coverage, desvios registrados (contagem).
2. Setar frontmatter do plano: `status: executado`.

```
🛑 FIM DA FASE 3 — EXECUÇÃO

✅ Entregáveis desta sessão:
- Branch: <branch-name>
- Commits: <N>
- Specs verdes: <ok/falhas>
- Coverage: 100%
- ACs implementados: <N>/<total>
- Desvios do plano registrados: <N>
- Handoff gravado no plano (status: executado)

📋 Próximo passo:
1. Encerre esta sessão (Ctrl+D ou /exit)
2. Abra uma nova sessão neste mesmo diretório
3. Execute: /ship

💾 Estado salvo na branch: <branch-name>
```

**Não pule este bloco. Não ofereça pra rodar o /ship na mesma sessão.**

### Encerramento por gap de escopo

Se a execução travou em gap de escopo (ver Política de desvio):

```
🛑 EXECUÇÃO BLOQUEADA — GAP DE ESCOPO

- Gap registrado em: ## Gap de escopo do plano
- Frontmatter do plano: status: bloqueado_replan
- Branch preservada: <branch-name> (commits até aqui mantidos)

📋 Próximo passo:
1. Encerre esta sessão
2. Nova sessão → /plan $ARGUMENTS (vai reler o gap e re-interrogar você)
3. Depois → /execute $ARGUMENTS de novo
```
