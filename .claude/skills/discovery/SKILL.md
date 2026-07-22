---
name: discovery
description: Fase 1 do fluxo — descoberta. Carrega o card de tasks e mapeia camadas afetadas.
argument-hint: NN
disable-model-invocation: true
---
# Fase 1 — Descoberta

**Argumento recebido:** `$ARGUMENTS`

## Objetivo

Analisar a issue presente na pasta tasks.

## Passos

1. **Validar argumento.** Se `$ARGUMENTS` não casar com `\d+`, parar e pedir o número da task (ex: `06`).

2. **Localizar e ler o card da task:**
   ```bash
   TASK_FILE=$(find ~/Obsidian/DriveCash/tasks -name "${ARGUMENTS}-*.md" | head -1)
   TASK_SLUG=$(basename "$TASK_FILE" .md)
   echo "Task: $TASK_SLUG"
   ```
   Se não encontrar, parar e listar as tasks disponíveis:
   ```bash
   ls ~/Obsidian/DriveCash/tasks/
   ```
   Ler o arquivo encontrado com `Read`. Extrair título (H1) e critérios de aceitação (seção "Acceptance criteria").

3. **Listar ACs.** Numerá-los a partir do arquivo da task.

4. **Mapear camadas afetadas** via `grep`/`find` direto no Bash (não usar subagents):
   - Schema/migrations: `db/schema.rb`, `db/migrate/`
   - Modelos: `app/models/`
   - Factories: `spec/factories/`
   - Services: `app/services/{domínio}/`
   - Views (Phlex): `app/views/`, `app/components/`
   - Controllers: `app/controllers/`
   - Routes: `config/routes.rb`
   - Specs: `spec/requests/`, `spec/models/`, `spec/services/`, `spec/components/`
   - i18n: `config/locales/`

5. **Interrogatório.** Com as camadas mapeadas, levantar tudo que o card **não** fixa:
   - edge cases e estados vazios
   - interação com features existentes
   - ACs ambíguos, conflitantes ou incompletos
   - comportamento em erro/limite

   Perguntar ao usuário via `AskUserQuestion`, quantas rodadas precisar. Cada resposta vira uma entrada em `## Decisões confirmadas` (pergunta + resposta). Se genuinamente não houver o que perguntar, registrar na seção: `Nenhuma pergunta — card completo.`

   **A fase não encerra com pergunta em aberto**: toda dúvida vira decisão confirmada ou risco aceito registrado no ADR. É esse registro que permite ao `/execute` rodar sem interromper o usuário.

6. **Salvar notas em Obsidian:**
   `/home/rebase/Obsidian/DriveCash/work/discovery/$TASK_SLUG.md`

   ### Formato esperado do arquivo:

   ```markdown
   ---
   card: TASK-$TASK_SLUG
   fase: discovery
   status: concluido
   context_hash: <resumo de 2 linhas do desafio técnico ou decisão principal>
   ---

   # TASK-$TASK_SLUG — Descoberta

   ## Card
   <título e descrição resumidos>

   ## ACs
   1. ...
   2. ...

   ## Camadas afetadas
   - Schema: <arquivos>
   - Models: <arquivos>
   - Services: <arquivos>
   - Views/Components: <arquivos>
   - Controllers: <arquivos>
   - Routes: <linhas>
   - Specs: <arquivos>
   - i18n: <chaves>

   ## Decisões confirmadas
   - **<pergunta feita ao usuário>** → <resposta>

   ## Arquitetura & Caminhos Descartados (ADR)
   - **Decisão:** <decisão principal tomada>
   - **Por que:** <justificativa>
   - **Descartado:** <o que não fazer e por que>

   ## Riscos aceitos
   - ...
   ```

7. **Rodar `/context` no terminal** (lembrar o usuário) — se já está em ~30%, alertar.

## Gate de débito técnico — [[11 - Checklist de Revisão]]

Antes de encerrar, valide as **decisões de arquitetura** desta descoberta (não o código — ele ainda não existe) contra os princípios da fase, de `~/Obsidian/DriveCash/rules/11 - Checklist de Revisão.md`:

**SRP · OCP · DIP · DRY · YAGNI · Model vs Service**

- Foco: *onde a lógica vai morar* — model vs service vs value object, o que estende em vez de editar (OCP), o que reusa em vez de duplicar (DRY), o que não criar ainda (YAGNI), limite de negócio ancorado no model.
- **Violação não resolvida → bloqueia.** Não encerre a descoberta. Apresente os achados ao usuário e aguarde.
- **Válvula registrada:** trade-off aceito conscientemente entra na seção `## Arquitetura & Caminhos Descartados (ADR)` como **Dívida aceita** (princípio violado / por que / custo e quando pagar). Nunca silenciosa.
- A partir de 22/06/2026, zero débito técnico novo: a fase não encerra com violação não resolvida e não registrada.

## ENCERRAMENTO OBRIGATÓRIO

Ao final, exibir literalmente:

```
🛑 FIM DA FASE 1 — DESCOBERTA

✅ Entregáveis desta sessão:
- Notas salvas em: ~/Obsidian/DriveCash/work/discovery/$TASK_SLUG.md
- ACs mapeados: <N>
- Camadas afetadas identificadas
- Decisões confirmadas com o usuário: <N>
- Perguntas em aberto: 0 (obrigatório)

📋 Próximo passo:
1. Encerre esta sessão (Ctrl+D ou /exit)
2. Abra uma nova sessão neste mesmo diretório
3. Execute: /plan $ARGUMENTS

💾 Estado salvo em: ~/Obsidian/DriveCash/work/discovery/$TASK_SLUG.md
```

**Não pule este bloco. Não ofereça pra continuar implementando na mesma sessão.**
