<!-- rtk-instructions v2 -->
# RTK (Rust Token Killer) - Token-Optimized Commands

## Golden Rule

**Always prefix commands with `rtk`**. If RTK has a dedicated filter, it uses it. If not, it passes through unchanged. This means RTK is always safe to use.

**Important**: Even in command chains with `&&`, use `rtk`:
```bash
# ❌ Wrong
git add . && git commit -m "msg" && git push

# ✅ Correct
rtk git add . && rtk git commit -m "msg" && rtk git push
```

## RTK Commands by Workflow

### Build & Compile (80-90% savings)
```bash
rtk cargo build         # Cargo build output
rtk cargo check         # Cargo check output
rtk cargo clippy        # Clippy warnings grouped by file (80%)
rtk tsc                 # TypeScript errors grouped by file/code (83%)
rtk lint                # ESLint/Biome violations grouped (84%)
rtk prettier --check    # Files needing format only (70%)
rtk next build          # Next.js build with route metrics (87%)
```

### Test (60-99% savings)
```bash
rtk cargo test          # Cargo test failures only (90%)
rtk go test             # Go test failures only (90%)
rtk jest                # Jest failures only (99.5%)
rtk vitest              # Vitest failures only (99.5%)
rtk playwright test     # Playwright failures only (94%)
rtk pytest              # Python test failures only (90%)
rtk rake test           # Ruby test failures only (90%)
rtk rspec               # RSpec test failures only (60%)
rtk test <cmd>          # Generic test wrapper - failures only
```

### Git (59-80% savings)
```bash
rtk git status          # Compact status
rtk git log             # Compact log (works with all git flags)
rtk git diff            # Compact diff (80%)
rtk git show            # Compact show (80%)
rtk git add             # Ultra-compact confirmations (59%)
rtk git commit          # Ultra-compact confirmations (59%)
rtk git push            # Ultra-compact confirmations
rtk git pull            # Ultra-compact confirmations
rtk git branch          # Compact branch list
rtk git fetch           # Compact fetch
rtk git stash           # Compact stash
rtk git worktree        # Compact worktree
```

Note: Git passthrough works for ALL subcommands, even those not explicitly listed.

### GitHub (26-87% savings)
```bash
rtk gh pr view <num>    # Compact PR view (87%)
rtk gh pr checks        # Compact PR checks (79%)
rtk gh run list         # Compact workflow runs (82%)
rtk gh issue list       # Compact issue list (80%)
rtk gh api              # Compact API responses (26%)
```

### JavaScript/TypeScript Tooling (70-90% savings)
```bash
rtk pnpm list           # Compact dependency tree (70%)
rtk pnpm outdated       # Compact outdated packages (80%)
rtk pnpm install        # Compact install output (90%)
rtk npm run <script>    # Compact npm script output
rtk npx <cmd>           # Compact npx command output
rtk prisma              # Prisma without ASCII art (88%)
```

### Files & Search (60-75% savings)
```bash
rtk ls <path>           # Tree format, compact (65%)
rtk read <file>         # Code reading with filtering (60%)
rtk grep <pattern>      # Search grouped by file (75%). Format flags (-c, -l, -L, -o, -Z) run raw.
rtk find <pattern>      # Find grouped by directory (70%)
```

### Analysis & Debug (70-90% savings)
```bash
rtk err <cmd>           # Filter errors only from any command
rtk log <file>          # Deduplicated logs with counts
rtk json <file>         # JSON structure without values
rtk deps                # Dependency overview
rtk env                 # Environment variables compact
rtk summary <cmd>       # Smart summary of command output
rtk diff                # Ultra-compact diffs
```

### Infrastructure (85% savings)
```bash
rtk docker ps           # Compact container list
rtk docker images       # Compact image list
rtk docker logs <c>     # Deduplicated logs
rtk kubectl get         # Compact resource list
rtk kubectl logs        # Deduplicated pod logs
```

### Network (65-70% savings)
```bash
rtk curl <url>          # Compact HTTP responses (70%)
rtk wget <url>          # Compact download output (65%)
```

### Meta Commands
```bash
rtk gain                # View token savings statistics
rtk gain --history      # View command history with savings
rtk discover            # Analyze Claude Code sessions for missed RTK usage
rtk proxy <cmd>         # Run command without filtering (for debugging)
rtk init                # Add RTK instructions to CLAUDE.md
rtk init --global       # Add RTK to ~/.claude/CLAUDE.md
```

## Token Savings Overview

| Category | Commands | Typical Savings |
|----------|----------|-----------------|
| Tests | vitest, playwright, cargo test | 90-99% |
| Build | next, tsc, lint, prettier | 70-87% |
| Git | status, log, diff, add, commit | 59-80% |
| GitHub | gh pr, gh run, gh issue | 26-87% |
| Package Managers | pnpm, npm, npx | 70-90% |
| Files | ls, read, grep, find | 60-75% |
| Infrastructure | docker, kubectl | 85% |
| Network | curl, wget | 65-70% |

Overall average: **60-90% token reduction** on common development operations.
<!-- /rtk-instructions -->

---

# DriveCash — Guia para Claude Code

## O que é o projeto

Aplicação Rails 8.1 para motoristas de delivery/gig workers rastrearem gastos e ganhos de múltiplas plataformas (Uber, iFood, Shopee etc.). Inclui chat com IA para registro rápido via linguagem natural.

## Stack

- **Backend**: Ruby 3.3.5, Rails 8.1.2, PostgreSQL 16
- **Frontend**: Phlex 2.2 (componentes Ruby, sem ERB), Stimulus, Turbo, Tailwind CSS
- **LLM**: Groq (primário, llama-3.3-70b) + Gemini (fallback), via Faraday
- **Testes**: RSpec, Factory Bot, SimpleCov (100% coverage obrigatório)
- **Deploy**: Kamal + Docker, Render (free tier — 2 workers Puma)
- **Locale**: pt-BR, fuso Brasília

## Comandos essenciais

O projeto roda via Docker. Sempre usar `rtk docker compose run --rm app` para executar comandos:

```bash
rtk docker compose run --rm app bundle exec rspec                    # roda toda a suite
rtk docker compose run --rm app bundle exec rspec spec/path/file     # spec específica
rtk docker compose run --rm app bundle exec rubocop                  # lint
rtk docker compose run --rm app bundle exec rails db:migrate         # migrações
rtk docker compose up -d db                                          # sobe o banco (necessário antes dos specs)
```

## Arquitetura em uma linha

`Controller → Service → Model → DB` com Views Phlex como presenters. Concerns para cross-cutting (cache, sessão, turbo streams).

## Regras críticas

- **Cobertura 100%**: SimpleCov bloqueia PR se cobertura cair. Toda linha nova precisa de spec.
- **Sem lógica em controllers**: lógica de negócio vai em Services (`app/services/{domínio}/`).
- **Service devolve payload semântico, não apresentação**: o retorno é estrutura + dados crus (números, chaves de enum, `Data`/hash). Cor/design token, `number_to_currency` e helpers de view ficam no component Phlex (que é Ruby — é o lar natural disso). Rótulo i18n 1:1 (`platforms.#{platform}`) pode ficar no service. Cálculo de domínio nunca convive com formatação no mesmo arquivo — extrair um calculador puro (ex: `Refuelings::VendorEfficiency`, `Dashboard::EarningsCalculator`).
- **Phlex, não ERB**: views são arquivos `.rb`, herdam de `ApplicationView` ou `ApplicationComponent`.
- **Turbo Streams**: respostas parciais via `RecordSaveResponse` concern — não redireciona.
- **Monetário**: sempre `decimal(10,2)`, concern `MonetaryAmount` converte string de input.
- **Cache**: sem invalidação automática. `Dashboard::AvailableYears.fetch` consulta o banco direto (overhead trivial). Se for cachear agregações pesadas no futuro, usar chave por-usuário (`"...#{user.id}"`).
- **LLM fallback**: se Groq falha (rate limit/config), cai automaticamente no Gemini.
- **i18n**: todas as strings visíveis em `config/locales/pt-BR.yml`.
- **Namespaces sempre no plural**: diretórios e módulos usam a forma plural (`module Vehicles`, `module Expenses`, `module Maintenances`). Nunca usar `class ModelName` para criar namespace — se o nome do namespace coincidir com um model AR (singular), renomear para plural. Isso evita o `TypeError: X is not a module`.

## Estrutura de serviços

```
app/services/
├── dashboard/   # StatsService, calculators, scope counters
├── ai/          # ParserService, ExpenseFromChat, SummaryBuilder, Tools/
├── chat/        # RecordPersister, ExpensePersister, EarningPersister
└── expenses/    # Creator, InstallmentCreator, InstallmentPlan
```

## Modelos e enums

```ruby
Expense.categories  # fuel, maintenance, car_wash, toll, parking,
                    # documentation, insurance, fine, meals, phone, other
Earning.platforms   # amazon, ifood, mercado_livre, nine_nine,
                    # rappi, shopee, uber, other
```

## Documentação completa

Ver vault Obsidian em `docs/` para regras detalhadas de testes, services, components, convenções e LLM.

## Design como fonte da verdade

O protótipo React é a **única fonte de verdade** para qualquer decisão visual. Nunca implementar UI por suposição ou memória.

### Arquivos do protótipo

```
/home/rebase/Downloads/Cosmic scale animation (1)/
├── screen-[nome].jsx       ← layout mobile de cada tela
├── screens-desktop.jsx     ← layout desktop de todas as telas
└── lib.jsx                 ← componentes compartilhados (BRL, Icon, etc.)
```

Vault Obsidian em `~/Obsidian/DriveCash/system-design/` — abrir com alias `design`.

### Regras obrigatórias por fase

**Discovery**: antes de qualquer discovery de tela, ler `screen-[nome].jsx` e a seção correspondente em `screens-desktop.jsx`. Extrair classes Tailwind, valores exatos, estrutura de grid e nomes de ícones. Nunca descrever o design de memória.

**Plan**: cada decisão visual deve citar o arquivo e linha de origem. Exemplo:
> `WeeklyBarsComponent`: labels "Seg/Ter…" no desktop — `screens-desktop.jsx:444`

Se uma linha do plan não tem referência ao protótipo, é suposição — revisar antes de executar.

**Execute**: antes de fechar qualquer tarefa de UI, tirar screenshot da tela e comparar item a item com o protótipo. Listar divergências explicitamente. Só marcar como concluído quando não houver diferença visual relevante.
