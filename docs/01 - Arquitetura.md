
# Arquitetura

## Visão Geral

```
HTTP Request
    ↓
Controller (fino — só roteamento e autorização)
    ↓
Service Object (toda a lógica de negócio)
    ↓
Model (validações, scopes, enums)
    ↓
PostgreSQL
    ↓
View Phlex (presenter — renderiza HTML via Ruby)
    ↓
Turbo Stream (resposta parcial ao browser)
```

## Camadas

### Controllers (`app/controllers/`)

Responsabilidade única: receber request, chamar service, devolver response. Sem lógica de negócio.

```ruby
# Padrão de controller
def create
  result = Expenses::Creator.call(expense_params)
  # RecordSaveResponse concern renderiza turbo_stream ou errors
  handle_save_response(result)
end
```

Concerns de controller:
- `DashboardContext` — filtros de data/mês compartilhados
- `ChatSession` — histórico de chat na sessão (máx 12 mensagens, FIFO)
- `RecordSaveResponse` — renderiza turbo_stream de sucesso ou erros

### Services (`app/services/{domínio}/`)

Toda lógica de negócio fica aqui. Ver [[04 - Regras de Services]].

```
app/services/
├── dashboard/    # cálculo de estatísticas e filtros
├── ai/           # orquestração LLM, parsing, coerção
├── chat/         # persistência de registros via chat
└── expenses/     # criação de despesas e parcelamentos
```

### Models (`app/models/`)

Responsabilidade: validações, enums, scopes, concerns de modelo. Sem lógica de negócio complexa.

Concerns de modelo:
- `MonetaryAmount` — converte string de input (vírgula → ponto) para decimal
- `CacheInvalidation` — limpa cache do dashboard no save/destroy

### Views (`app/views/` + `app/components/`)

Phlex em vez de ERB. Views são classes Ruby. Ver [[05 - Regras de Components]].

### LLM (`lib/llm/`)

Adapters para Groq e Gemini com fallback automático. Ver [[06 - Integração LLM]].

## Módulos e Domínios

| Módulo | Namespace | Responsabilidade |
|--------|-----------|-----------------|
| Dashboard | `Dashboard::` | estatísticas, filtros, gráficos |
| Chat | `Chat::` | sessão, histórico, persistência via IA |
| Expenses | `Expenses::` | criação, parcelamentos, edição |
| AI | `Ai::` | parsing LLM, coerção de dados |
| LLM | `Llm::` | client HTTP, adapters, retry |

## Cache

- **Motor**: Solid Cache (in-process)
- **Chave**: `dashboard/available_years`
- **Invalidação**: automática via `CacheInvalidation` concern no after_commit
- **Memoização interna**: `@var ||=` nos services para evitar queries repetidas

## Sessão

- Chat history na Rails session (máx 12 mensagens)
- `ChatSession` concern: `chat_history`, `add_to_history`, `clear_history`

## Relacionado

- [[02 - Banco de Dados]]
- [[04 - Regras de Services]]
- [[05 - Regras de Components]]
- [[06 - Integração LLM]]
