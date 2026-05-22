
# CI/CD

## GitHub Actions (`.github/workflows/ci.yml`)

Dois jobs em sequência:

```
push / PR
    ↓
[lint] Rubocop
    ↓ (depende de lint passar)
[test] RSpec + SimpleCov
```

### Job: Lint

```yaml
runs-on: ubuntu-latest
steps:
  - ruby setup (via .ruby-version)
  - bundler cache
  - bundle exec rubocop -f github
```

Qualquer violação Rubocop = CI quebrado. PR não pode ser mergeado.

### Job: Test

```yaml
runs-on: ubuntu-latest
services:
  postgres:
    image: postgres:15
    env: POSTGRES_PASSWORD=...
    healthcheck: pg_isready

env:
  DATABASE_URL: postgresql://...
  LLM_API_KEY: test-key-dummy
  LLM_FALLBACK_API_KEY: test-key-dummy

steps:
  - ruby setup
  - bundler cache
  - bundle exec rails db:migrate
  - bundle exec rails tailwindcss:build
  - bundle exec rspec
```

### Cobertura 100%

SimpleCov é configurado para falhar se a cobertura cair abaixo de 100%. Toda linha de código nova precisa de spec correspondente.

```ruby
# spec/rails_helper.rb (simplificado)
SimpleCov.start 'rails' do
  minimum_coverage 100
end
```

Se o CI falhar com `Coverage (98.5%) is below the expected minimum coverage (100.0%).`:
1. Identifique quais linhas não têm cobertura no relatório
2. Adicione specs para cobrir essas linhas
3. Não use `# :nocov:` como atalho — cubra o código de verdade

## Deploy (Kamal + Docker)

### Stack de deploy

- **Kamal** — ferramenta de deploy da Basecamp (substitui Capistrano)
- **Docker** — container da aplicação
- **Render** — hosting (free tier: 2 workers Puma, 2-5 threads)

### Arquivos relevantes

```
.kamal/
├── deploy.yml      # configuração do Kamal
└── hooks/          # hooks pre/post deploy
Dockerfile          # imagem de produção
Dockerfile.dev      # imagem de desenvolvimento
docker-compose.yml  # stack local (app + postgres)
```

### Comandos de deploy

```bash
kamal deploy          # deploy completo
kamal app logs        # logs da aplicação em produção
kamal app exec bash   # acesso ao container em produção
```

### Configuração de produção

```ruby
# config/puma.rb (otimizado para Render free tier)
threads_count = ENV.fetch("RAILS_MAX_THREADS", 5)
threads threads_count, threads_count
workers ENV.fetch("WEB_CONCURRENCY", 2)
```

## Variáveis de Ambiente (Produção)

```bash
DATABASE_URL=postgresql://...
SECRET_KEY_BASE=...
LLM_PROVIDER=groq
LLM_API_KEY=gsk_...
LLM_FALLBACK_API_KEY=AI...
RAILS_ENV=production
RAILS_LOG_TO_STDOUT=true
```

Ver `.env.example` para lista completa.

## Checklist antes de PR

- [ ] `rtk bundle exec rubocop` sem erros
- [ ] `rtk bundle exec rspec` 100% cobertura, zero falhas
- [ ] Migrações adicionadas se o schema mudou
- [ ] `config/locales/pt-BR.yml` atualizado se strings novas
- [ ] Nenhuma chave de API ou secret no código

## Relacionado

- [[03 - Regras de Testes]]
- [[07 - Convenções]]
