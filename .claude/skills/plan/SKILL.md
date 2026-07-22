---
name: plan
description: Fase 2 do fluxo — planejamento. Gera plano técnico em Obsidian a partir das notas de descoberta.
argument-hint: NN
disable-model-invocation: true
---

# Fase 2 — Planejamento

Argumento recebido: $ARGUMENTS

## Pré-condição

1. **Derivar slug e verificar que descoberta existe e está concluída:**
   ```bash
   TASK_FILE=$(find ~/Obsidian/DriveCash/tasks -name "${ARGUMENTS}-*.md" | head -1)
   TASK_SLUG=$(basename "$TASK_FILE" .md)
   DISCOVERY="/home/rebase/Obsidian/DriveCash/work/discovery/$TASK_SLUG.md"
   grep "^status:" "$DISCOVERY"
   ```
   Se o arquivo não existir ou o status não for `concluido`, parar e pedir pra rodar `/discovery $ARGUMENTS` antes.

2. **Replan?** Se `work/plans/$TASK_SLUG.md` já existe com `status: bloqueado_replan`, o `/execute` devolveu a task com gap de escopo: ler a seção `## Gap de escopo`, re-interrogar o usuário sobre o gap (`AskUserQuestion`), re-planejar **apenas o trecho afetado**, remover a seção e seguir o fechamento normal.

3. **Ler notas de descoberta** (com `Read`, não recopiar conteúdo no chat) — em especial `## Decisões confirmadas`: são decisões já tomadas pelo usuário, não reabrir.

4. **Ler o card da task** para confirmar título exato — usar `Read` em `$TASK_FILE`.

## Geração do plano

5. **Ler os arquivos existentes** que serão modificados — models, specs, factories, services, components relevantes identificados na descoberta. O plano deve refletir o estilo e estrutura do que já existe, não gerar do zero.

6. **Invocar skill `superpowers:writing-plans`** com o contexto:
   - ACs do card da task
   - Camadas mapeadas na descoberta
   - Conteúdo dos arquivos existentes lidos no passo anterior
   - Padrões do projeto (ler CLAUDE.md e rules em `/home/rebase/Obsidian/DriveCash/rules/`)

7. **Regras obrigatórias do DriveCash** ao gerar o plano:
   - Views são Phlex (`.rb`), nunca ERB
   - Lógica de negócio em `app/services/{domínio}/`, não em controllers
   - Monetário sempre `decimal(10,2)` com concern `MonetaryAmount`
   - Cache invalidado via `CacheInvalidation` concern em save/destroy
   - Turbo Streams para respostas parciais via `RecordSaveResponse` concern
   - i18n em `config/locales/pt-BR.yml` para toda string visível
   - 100% coverage obrigatório (SimpleCov bloqueia se cair)
   - Comandos sempre com `rtk docker compose run --rm app bundle exec ...`

8. **Interrogatório técnico.** Toda decisão de implementação com mais de um caminho razoável que o discovery **não** fixou (abordagem, estrutura de componente, formato de dado, trade-off de performance) → perguntar via `AskUserQuestion` e registrar em `## Decisões confirmadas` do plano. O `/execute` não pergunta nada ao usuário: o que não estiver fixado aqui vira desvio decidido pela LLM ou replan.

9. **Salvar plano em:**
   `/home/rebase/Obsidian/DriveCash/work/plans/$TASK_SLUG.md`

10. **Formato obrigatório:**

    ```yaml
    ---
    card: TASK-$TASK_SLUG
    fase: plan
    status: pronto_para_execucao
    links_relacionados:
      - "[[work/discovery/$TASK_SLUG]]"
    ---
    ```

    - **H1 exato:** `# [TASK-$TASK_SLUG] <título exato do card>` — sem sufixo em inglês
    - **Mapear cada AC** para o `it`/`context` do spec correspondente
    - **Comandos do plano** devem ser literais (sem placeholder), copiáveis 1:1
    - **Não inventar colunas/campos** — só usar o que existe no schema atual (`db/schema.rb`)
    - **Checklist por AC** — cada item com `- [ ]` para marcar durante execução
    - **Seção `## Decisões confirmadas`** — respostas do interrogatório técnico
    - **Seções `## Desvios do plano` e `## Handoff de execução`** — criadas vazias; o `/execute` preenche

## Gate de débito técnico — [[11 - Checklist de Revisão]]

Antes de encerrar, valide o plano (classes, caminhos, assinaturas, mapeamento de specs) contra os princípios da fase, de `~/Obsidian/DriveCash/rules/11 - Checklist de Revisão.md`:

**SRP · OCP · DIP · DRY · YAGNI · Model vs Service · Testabilidade · Rails Way**

- O plano fixa onde cada classe nasce e como será testada — último ponto barato pra corrigir altitude antes do código existir. Confirme: value object em `models/` (não `services/`), limite de negócio com `validates` no model, despacho por registry (não `case/when`), nenhum param/abstração sem uso real hoje, cada AC mapeado a um spec de comportamento.
- **Violação não resolvida → bloqueia.** Não encerre o plano. Apresente os achados ao usuário e aguarde.
- **Válvula registrada:** trade-off aceito conscientemente vai pra seção `## Arquitetura & Caminhos Descartados (ADR)` do discovery (`work/discovery/<slug>.md`) como **Dívida aceita**.
- Zero débito técnico novo: a fase não encerra com violação não resolvida e não registrada.

## ENCERRAMENTO OBRIGATÓRIO

```
🛑 FIM DA FASE 2 — PLANEJAMENTO

✅ Entregáveis desta sessão:
- Plano salvo em: ~/Obsidian/DriveCash/work/plans/$TASK_SLUG.md
- Cada AC mapeado para spec correspondente
- Plano revisado quanto a fidelidade ao schema/codebase
- Decisões confirmadas com o usuário: <N>
- Frontmatter: status: pronto_para_execucao

📋 Próximo passo:
1. Encerre esta sessão (Ctrl+D ou /exit)
2. Abra uma nova sessão neste mesmo diretório
3. Execute: /execute $ARGUMENTS

💾 Estado salvo em: ~/Obsidian/DriveCash/work/plans/$TASK_SLUG.md
```

**Não pule este bloco. Não ofereça pra "começar a implementar agora que o plano tá pronto".**
