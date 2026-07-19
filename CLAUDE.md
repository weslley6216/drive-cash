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

**Gems**: `docker compose build` NÃO atualiza gems — elas vivem no volume `ruby_gems` (que sobrescreve o bundle da imagem), e o `entrypoint.sh` aborta antes de qualquer comando quando o bundle está defasado. Ao ver `Bundler::GemNotFound`/`Could not find <gem>`, ir direto para:

```bash
rtk docker compose run --rm --entrypoint bundle app install
```

Nunca apagar o volume `ruby_gems` (destrutivo, reinstala tudo à toa).

## Arquitetura em uma linha

`Controller → Service → Model → DB` com Views Phlex como presenters. Concerns para cross-cutting (cache, sessão, turbo streams).

## Regras críticas

- **Cobertura 100%**: SimpleCov bloqueia PR se cobertura cair. Toda linha nova precisa de spec.
- **Sem lógica em controllers**: lógica de negócio vai em Services (`app/services/{domínio}/`).
- **Service devolve payload semântico, não apresentação**: o retorno é estrutura + dados crus (números, chaves de enum, `Data`/hash). Cor/design token, `number_to_currency` e helpers de view ficam no component Phlex (que é Ruby — é o lar natural disso). Rótulo i18n 1:1 (`platforms.#{platform}`) pode ficar no service. Cálculo de domínio nunca convive com formatação no mesmo arquivo — extrair um calculador puro (ex: `Refuelings::VendorEfficiency`, `Dashboard::EarningsCalculator`).
- **Onde a lógica mora (Service vs Value Object vs Model)**: *Service* orquestra e tem efeito colateral (persiste, transação, API) — `services/`. *Value Object* de domínio recebe dados, calcula e responde, imutável e sem banco — se nomeia um conceito do domínio e carrega invariante, vive em `models/{domínio}/` (ex: `Expenses::InstallmentPlan`); calculador puro de passo sem invariante (ex: `Dashboard::PercentChange`, `MaintenanceStatus`) pode seguir em `services/`. **Limite de negócio (`MAX_*`, `MIN_*`) é invariante do model AR**: o limite e a `validates` correspondente moram no model (ex: `Expense::MAX_INSTALLMENTS` + `validates :installment_count`), e o value object referencia a constante do model — nunca só no value object/service, senão dá pra criar registro inválido direto pelo model.
- **Phlex, não ERB**: views são arquivos `.rb`, herdam de `ApplicationView` ou `ApplicationComponent`.
- **Turbo Streams via concern, nunca inline no controller**: toda resposta Turbo padronizada vive num concern, não repetida em cada action. Dois padrões: (1) render parcial de view Phlex com totais — `RecordSaveResponse` (`turbo_success`/`turbo_error`/`turbo_render_list`); (2) fecha modal + refresh de página inteira (Turbo morphing) — `ModalRefreshResponse#respond_with_modal_refresh(html_redirect:)`, usado pela família de veículo/goals. Guard `before_action` compartilhado entre controllers da mesma família também vira concern (ex: `RequiresVehicle`). Nunca montar `render turbo_stream: [...]` à mão dentro de uma action.
- **Monetário**: sempre `decimal(10,2)`, concern `MonetaryAmount` converte string de input.
- **Cache**: sem invalidação automática. `Dashboard::AvailableYears.fetch` consulta o banco direto (overhead trivial). Se for cachear agregações pesadas no futuro, usar chave por-usuário (`"...#{user.id}"`).
- **LLM fallback**: se Groq falha (rate limit/config), cai automaticamente no Gemini.
- **i18n**: todas as strings visíveis em `config/locales/pt-BR.yml`.
- **Namespaces sempre no plural**: diretórios e módulos usam a forma plural (`module Vehicles`, `module Expenses`, `module Maintenances`). Nunca usar `class ModelName` para criar namespace — se o nome do namespace coincidir com um model AR (singular), renomear para plural. Isso evita o `TypeError: X is not a module`.
- **Variação de domínio estende, não edita (OCP)**: conjunto que cresce (período de parcelamento, tipo de insight, ferramenta de chat, filtro de histórico) despacha via registry de dados ou uma classe por variante resolvida por convenção — nunca `case/when`/`if-elsif` espalhado por vários arquivos. Adicionar uma variante = uma entrada declarativa + suas classes colaboradoras, sem tocar na lógica de despacho. Registries: `Expenses::InstallmentPlan::PERIOD_ADVANCE`, `Dashboard::Insights::Presenters` (um presenter por tipo), `Ai::Tools::Registry`, `History::FeedService::FILTERS`. Mapa de lookup com fallback default (paletas) também conta como registry. **OCP não revoga SRP**: o registry referencia colaboradores, não os contém — cálculo de domínio e apresentação seguem em classes separadas.

## Convenções de código

- **Sem comentários em `.rb`**: nunca escrever `# ...` em arquivos Ruby — nem explicativos, nem de contexto. O código se explica por nomes de métodos e variáveis.
- **Sem variáveis de bloco de uma letra**: `|record|` não `|r|`, `|group|` não `|g|`, `|offset|` não `|i|`; usar o nome do domínio (`|earning|`, `|expense|`) quando o tipo é conhecido.
- **Controllers só têm actions**: nenhum método privado — resposta Turbo, session/nonce e orquestração pós-confirm vão para concerns (ex: `ChatSession`); a action fica com params, chamada de service/concern e redirect/head.
- **Idiomas**: código, commits e símbolos Ruby em inglês; strings visíveis ao usuário via i18n em pt-BR; comunicação humana (descrições, docs de fluxo) em pt-BR.

## Convenções de specs (RSpec)

- **Sem `let!`**: usar `let` + referência explícita, `before { create(...) }` ou create dentro do `it`.
- **AAA com linha vazia** entre Arrange/Act/Assert quando as três fases estão no `it`; se Arrange/Act estão em `let`, o `it` só tem o Assert. Nunca comentários (`# Arrange`) — nem qualquer outro comentário em spec.
- **Sem `expect_any_instance_of`/`allow_any_instance_of`**: mockar classe/instância específica (`allow(MyClass).to receive(...)`) ou testar o comportamento resultante.
- **Sem referência a ACs** (`(AC 1)`) nos nomes dos exemplos — descrever o comportamento; o nome deve fazer sentido sozinho.
- **Teste só-negativo exige par positivo discriminante**: exemplo cuja única asserção é negativa (`not_to include/match/have_key`) sem um exemplo positivo de estado oposto na mesma área verifica ausência permanente — passa para sempre e não detecta regressão; não escrever, remover se existir. Exceções legítimas (têm estado-par): `not_to be_valid`, isolamento entre usuários, filtros/scopes, elementos condicionais. Detalhe: `rules/03 - Regras de Testes.md` no vault.

## Fluxo de trabalho e git

- **Fluxo v2 (desde 17/07/2026, sem PR)**: `/discovery NN` → `/plan NN` → `/execute NN` → `/ship`. Os gates do `/ship` substituem a revisão de PR: um único OK humano, depois `git merge --no-ff` na main + push + cleanup (ADR → `decisions/`, task → `done/`). Handoff via frontmatter `status`; perguntas ao usuário só em discovery/plan — execute é autônomo (desvio tático registra, gap de escopo devolve pro plan). As skills do fluxo vivem em `~/Obsidian/DriveCash/skills/` (fonte, editável no Obsidian), symlinkadas em `.claude/skills/<nome>/SKILL.md`.
- **Commit trivial (docs/chore/fix de 1 linha) vai direto na main + push**, sem branch; branch + `/ship` é para feature de verdade.
- **Commits**: 100% em inglês, Conventional Commits (`feat:`, `fix:`, `refactor:`, `test:`, `chore:`, `docs:`…), sem `Co-authored-by`.
- **Artefatos do fluxo no vault**: planos em `~/Obsidian/DriveCash/work/plans/` (nunca `docs/plans/`); arquivos de discovery concisos no padrão de `01-bottom-nav-layout.md` — lista simples por camada, ACs em uma linha, máx. 2 decisões de ADR, sem sub-seções nem checklist final.

## Estrutura de serviços

```
app/services/
├── ai/             # ParserService, ExpenseFromChat, Tools/ (Registry), Readers/, prompts/
├── chat/           # RecordPersister + persisters por tool, Payload, InstallmentInfo
├── dashboard/      # StatsService, calculators, insights/, scope counters
├── earnings/       # Creator
├── expenses/       # Creator, InstallmentCreator
├── exports/        # Builder, generators/ (Pdf, Csv, Json), Registry
├── goals/          # Creator, ProgressService, AchievementsService
├── history/        # FeedService (registry FILTERS), RecordSearch
├── notifications/  # generators/ por kind, Registry, Sweeper, Grouping
├── refuelings/     # Creator, Updater, Moves, VendorEfficiency
└── vehicles/       # MaintenanceService, TankBalanceService, TankStatus, Statistics
```

Camada de apresentação por domínio em `app/presenters/` (chat/answers, chat/summaries, dashboard/insights, history/entry_rows, notifications) — prepara dados crus para as views Phlex; é o lar dos registries "um presenter por variante".

Value objects de domínio (sem persistência, sem efeito colateral, com invariante própria) vivem em `app/models/{domínio}/`, não em `app/services/`. Ex: `Expenses::InstallmentPlan`, `Exports::PeriodRange`, `Plans::Catalog`.

Jobs (`app/jobs/`) são casca fina sobre Solid Queue — hoje só `ExportJob`.

## Modelos e enums

```ruby
Expense.categories      # fuel, maintenance, car_wash, toll, parking,
                        # documentation, insurance, fine, meals, phone, other
Earning.platforms       # amazon, ifood, mercado_livre, nine_nine,
                        # rappi, shopee, uber, other
Maintenance.categories  # oil_change, oil_filter, air_filter, fuel_filter,
                        # tire_rotation, brake_pads, spark_plugs, timing_belt
Goal::KINDS             # weekly, monthly, annual   (enum string)
Goal::METRICS           # profit, earnings          (enum string)
Export                  # period_kind: this_month/last_month/year/custom ·
                        # format: pdf/csv/json · status: pending/processing/done/failed
User.plans              # free, pro (+ plan_billing: monthly/yearly)
Notification            # kind validado contra Notifications::Registry::KINDS
```

Relações: `User has_many expenses/earnings/goals/exports/notifications` + `has_one :vehicle`; `Vehicle has_many maintenances/refuelings`; `Refueling belongs_to :expense` (opcional). Scopes financeiros compartilhados no concern `FinancialEntry` (`for_year`, `for_month`, `in_period`, `chronological`).

## Documentação completa

Vault Obsidian em `~/Obsidian/DriveCash/` — regras detalhadas em `rules/` (arquitetura, banco, testes, services, components, LLM, convenções, checklist de revisão), ADRs em `decisions/`, cards em `tasks/`. O diretório `docs/` deste repo não é usado.

## Design como fonte da verdade

O protótipo React é a **única fonte de verdade** para qualquer decisão visual. Nunca implementar UI por suposição ou memória.

### Arquivos do protótipo

```
/home/rebase/Downloads/Cosmic scale animation/
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
