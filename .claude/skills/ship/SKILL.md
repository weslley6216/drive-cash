---
name: ship
description: Fase 4 do fluxo — ship. Roda os gates de qualidade e mergeia direto na main após um único OK.
disable-model-invocation: true
---

# Fase 4 — Ship

Merge direto na main: os gates desta fase substituem a revisão de PR. O único checkpoint humano é o OK antes do merge.

## Pré-condições

1. **Branch atual** deve ser `feature/NN-...` (ex: `feature/01-bottom-nav-layout`):
   ```bash
   git branch --show-current
   ```

2. **Sem mudanças não commitadas:**
   ```bash
   git status --short
   ```
   Se houver, parar e perguntar.

3. **Derivar task e validar handoff do execute:**
   ```bash
   CARD=$(git branch --show-current | grep -oP '\d+' | head -1)
   TASK_FILE=$(find ~/Obsidian/DriveCash/tasks -name "${CARD}-*.md" | head -1)
   TASK_SLUG=$(basename "$TASK_FILE" .md)
   PLAN="/home/rebase/Obsidian/DriveCash/work/plans/$TASK_SLUG.md"
   DISCOVERY="/home/rebase/Obsidian/DriveCash/work/discovery/$TASK_SLUG.md"
   grep "^status:" "$PLAN"
   ```
   Se o status não for `executado`, parar e apontar `/execute $CARD`.

## Gates (autônomos)

Rodar os três blocos. **Achado → corrigir → commitar → re-rodar o bloco até verde.** Não pedir confirmação pra corrigir; toda correção entra na lista do checkpoint. Exceção: violação cuja correção mudaria escopo/AC não é corrigida — vira pendência de **Dívida aceita** apresentada no checkpoint.

4. **Checklist mecânico DriveCash:**
   - [ ] Nenhuma lógica de negócio em controllers
   - [ ] Views são Phlex (`.rb`), não ERB
   - [ ] Strings visíveis em `config/locales/pt-BR.yml`
   - [ ] Campos monetários como `decimal(10,2)`
   - [ ] Respostas parciais via Turbo Streams (`RecordSaveResponse`)
   - [ ] SimpleCov em 100%:
     ```bash
     rtk docker compose run --rm app bundle exec rspec
     ```
   - [ ] Rubocop sem ofensas:
     ```bash
     rtk docker compose run --rm app bundle exec rubocop
     ```

5. **Gate de débito técnico — os 13 princípios**, de `~/Obsidian/DriveCash/rules/11 - Checklist de Revisão.md` (ver [[11 - Checklist de Revisão]]), sobre o diff completo da branch (`git diff main...HEAD`):

   **SRP · OCP · DIP · DRY · YAGNI · Testabilidade · Segurança · N+1 · Rails Way · Phlex · Legibilidade · Código Morto · Model vs Service**

   Nenhum merge acontece com débito técnico novo não resolvido e não registrado.

6. **Code review:** invocar `superpowers:requesting-code-review` para validar a implementação contra os padrões do projeto (Phlex, services, cobertura, i18n etc.). Achados entram no mesmo ciclo corrigir → commitar → re-rodar.

## Checkpoint único (o OK humano)

7. Apresentar em uma tela, e **aguardar o OK do usuário**:
   - Diff resumido: `rtk git diff main...HEAD --stat`
   - Resultado dos gates: mecânico / 13 princípios / code review
   - `## Desvios do plano` (ler de `$PLAN`)
   - Correções feitas pelos próprios gates (commits desta fase)
   - Pendências que exigem decisão (ex: Dívida aceita) — se houver, resolver antes de prosseguir

   **Nenhum merge antes do OK. Sem OK, sem push.**

## Merge e push

8. Após o OK:
   ```bash
   BRANCH=$(git branch --show-current)
   git checkout main && git pull
   git merge --no-ff "$BRANCH"
   git push
   git branch -d "$BRANCH"
   ```

## Cleanup

9. **ADR + desvios → decisions/:** ler `## Arquitetura & Caminhos Descartados (ADR)` do discovery e `## Desvios do plano` do plano. Salvar em `/home/rebase/Obsidian/DriveCash/decisions/$TASK_SLUG.md`:

   ```markdown
   ---
   task: $TASK_SLUG
   merged: <data de hoje>
   ---

   # ADR — <título da task>

   <conteúdo da seção ADR do discovery, sem alteração>

   ## Desvios do plano

   <conteúdo da seção do plano — omitir este bloco se vazia>
   ```

10. **Marcar ACs como concluídos na task e mover para `done/`:**
    ```bash
    sed -i 's/- \[ \]/- [x]/g' "$TASK_FILE"
    mv "$TASK_FILE" "/home/rebase/Obsidian/DriveCash/tasks/done/$TASK_SLUG.md"
    ```

11. **Apagar arquivos de trabalho:**
    ```bash
    rm -f "$DISCOVERY" "$PLAN"
    ```

## ENCERRAMENTO

```
🛑 FIM DA FASE 4 — SHIP

✅ Task $CARD entregue:
- Merge: main ← <branch> (--no-ff, pushed)
- Gates: mecânico ✔ · 13 princípios ✔ · code review ✔
- Correções feitas nos gates: <N>
- ADR + desvios salvos em: decisions/$TASK_SLUG.md
- Task movida para: tasks/done/$TASK_SLUG.md (ACs marcados)
- work/ limpo, branch local deletada
```
