
# Integração LLM

## Visão Geral

O chat IA permite que o usuário registre gastos e ganhos em linguagem natural. A IA interpreta a mensagem e cria os registros automaticamente.

**Fluxo:**

```
Mensagem do usuário
    ↓
ChatController#create
    ↓
Ai::ParserService.call(message:, history:)
    ↓
Llm::Client (adapter chain)
    ↓ (tenta Groq primeiro)
Llm::Adapters::Groq  ──fallback→  Llm::Adapters::Gemini
    ↓
Resposta com tool_call (JSON estruturado)
    ↓
Ai::ExpenseFromChat (coerce atributos)
    ↓
Chat::RecordPersister (salva no banco)
    ↓
Turbo Stream (atualiza UI)
```

## Providers

### Groq (primário)

- Modelo: `llama-3.3-70b-versatile`
- API compatível com OpenAI
- Tool calling via array `tool_calls` na resposta
- Configuração: `LLM_PROVIDER=groq`, `LLM_API_KEY=gsk_...`

### Gemini (fallback)

- Modelo: `gemini-2.0-flash` (ou configurável)
- API própria do Google
- Tool calling via `functionCall` no `candidates[0].content.parts`
- Ativado automaticamente quando Groq retorna rate limit (429) ou erro de config

### Seleção de Provider

```ruby
# lib/llm/client.rb
def call(messages:, tools:)
  primary_adapter.call(messages:, tools:)
rescue Llm::RateLimitError, Llm::ConfigurationError
  fallback_adapter.call(messages:, tools:)
end
```

## Adapters

Todos os adapters herdam de `Llm::BaseAdapter`:

```ruby
# lib/llm/base_adapter.rb
class BaseAdapter
  def initialize(api_key:)
    @conn = Faraday.new do |f|
      f.request :retry, max: 3, interval: 1, backoff_factor: 2,
                        exceptions: [Faraday::TimeoutError, Faraday::ConnectionFailed]
      f.response :raise_error
      f.adapter Faraday.default_adapter
    end
  end
end
```

Cada adapter implementa:
- `#chat(messages:, tools:)` → resposta normalizada
- `#extract_tool_call(response)` → extrai `{ name:, arguments: }` do formato específico

## Tool Calling (Function Calling)

As "ferramentas" são schemas JSON que dizem à IA quais funções pode chamar.

Declarações em `app/services/ai/tools/`:

```ruby
# app/services/ai/tools/record_expense.rb
module Ai
  module Tools
    RECORD_EXPENSE = {
      type: "function",
      function: {
        name: "record_expense",
        description: "Registra uma nova despesa do motorista",
        parameters: {
          type: "object",
          properties: {
            amount:      { type: "number",  description: "Valor em reais" },
            category:    { type: "string",  enum: Expense.categories.keys },
            date:        { type: "string",  description: "Data no formato YYYY-MM-DD" },
            description: { type: "string",  description: "Descrição opcional" },
            vendor:      { type: "string",  description: "Fornecedor/local opcional" }
          },
          required: ["amount", "category", "date"]
        }
      }
    }.freeze
  end
end
```

## Coerção de Dados (ExpenseFromChat)

O JSON vindo do LLM pode ter formatos variados. `Ai::ExpenseFromChat` normaliza:

```ruby
# Transforma {"amount": 150.5, "category": "fuel", "date": "2024-03-01"}
# em atributos seguros para Expense.new(...)

def self.call(tool_args)
  {
    amount:      tool_args["amount"].to_s,       # MonetaryAmount vai converter
    category:    tool_args["category"],
    date:        Date.parse(tool_args["date"]),
    description: tool_args["description"],
    vendor:      tool_args["vendor"]
  }
end
```

## Histórico de Conversa

Até 12 mensagens armazenadas na sessão Rails. Gerenciado pelo concern `ChatSession`:

```ruby
# Adiciona mensagem ao histórico
add_to_history(role: "user", content: "gastei 50 reais de combustível")
add_to_history(role: "assistant", content: "Registrei: combustível R$ 50,00")

# Histórico enviado para o LLM como contexto
chat_history  # => [{role:, content:}, ...]
```

O histórico é enviado como `messages` para o LLM em toda requisição, dando contexto conversacional.

## Tratamento de Erros LLM

```ruby
module Llm
  class Error              < StandardError; end
  class RateLimitError     < Error; end  # 429, 503 → tenta fallback
  class ConfigurationError < Error; end  # API key ausente → tenta fallback
end
```

Erros que não são rate limit ou config são propagados normalmente.

## Variáveis de Ambiente

```bash
LLM_PROVIDER=groq           # ou "gemini"
LLM_API_KEY=gsk_...         # Groq API key
LLM_FALLBACK_API_KEY=AI...  # Gemini API key (para fallback)
```

Ver `.env.example` na raiz do projeto.

## Relacionado

- [[01 - Arquitetura]]
- [[04 - Regras de Services]]
- [[03 - Regras de Testes]]
