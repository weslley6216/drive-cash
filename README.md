# DriveCash

Aplicativo para motoristas de delivery e gig workers rastrearem gastos e ganhos de múltiplas plataformas. Inclui um assistente de IA para registro rápido via linguagem natural.

## Funcionalidades

- **Dashboard** com resumo financeiro — ganhos, despesas, lucro, dias trabalhados e número de corridas, com visão mensal e anual
- **Registro de ganhos** por plataforma (Uber, iFood, Rappi, Shopee, Amazon, Mercado Livre, 99, outras)
- **Registro de despesas** por categoria (combustível, manutenção, pedágio, seguro, multa e mais) com suporte a parcelamento
- **Assistente Caju** — chat com IA para registrar gastos e ganhos em linguagem natural, sem preencher formulários
- **PWA** — instalável no celular como aplicativo nativo

## Stack

| Camada | Tecnologia |
|--------|-----------|
| Backend | Ruby 3.3.5, Rails 8.1 |
| Banco de dados | PostgreSQL 16 |
| Frontend | Phlex 2, Stimulus, Turbo, Tailwind CSS 4 |
| IA | Groq (llama-3.3-70b) + Gemini (fallback) |
| Testes | RSpec, Factory Bot, SimpleCov (100%) |
| Deploy | Kamal + Docker |

## Rodando localmente

**Pré-requisitos:** Docker e Docker Compose.

```bash
# Clone o repositório
git clone https://github.com/weslley6216/drive-cash.git
cd drive-cash

# Configure as variáveis de ambiente
cp .env.example .env
# Edite .env com suas chaves de API (GROQ_API_KEY ou GEMINI_API_KEY)

# Suba o banco de dados
docker compose up -d db

# Configure o banco e inicie o servidor
docker compose up app
```

Acesse `http://localhost:3000`.

## Variáveis de ambiente

| Variável | Descrição | Obrigatório |
|----------|-----------|-------------|
| `DATABASE_URL` | URL de conexão com o PostgreSQL | Sim |
| `GROQ_API_KEY` | Chave da API Groq (LLM primário) | Para o chat |
| `GEMINI_API_KEY` | Chave da API Gemini (fallback) | Para o chat |
| `GROQ_MODEL` | Modelo Groq (padrão: `llama-3.3-70b-versatile`) | Não |
| `GEMINI_MODEL` | Modelo Gemini (padrão: `gemini-2.0-flash`) | Não |

## Comandos úteis

```bash
# Testes
docker compose run --rm app bundle exec rspec

# Lint
docker compose run --rm app bundle exec rubocop

# Migrações
docker compose run --rm app bundle exec rails db:migrate
```

## Plataformas suportadas

`Uber` · `iFood` · `Rappi` · `Shopee` · `Amazon` · `Mercado Livre` · `99` · `Outras`

## Categorias de despesa

**Veículo:** Combustível · Manutenção · Lavagem · Pedágio · Estacionamento · Documentação · Seguro · Multa

**Operacional:** Refeições · Telefone · Outros

## Licença

MIT
