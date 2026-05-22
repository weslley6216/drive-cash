
# DriveCash — Base de Conhecimento

Aplicação Rails 8.1 para motoristas de delivery rastrearem gastos e ganhos com chat IA integrado.

## Navegação

### Fundamentos
- [[01 - Arquitetura]] — visão geral da arquitetura, camadas e fluxo de dados
- [[02 - Banco de Dados]] — schema, enums, índices e padrões de persistência

### Regras de Desenvolvimento
- [[03 - Regras de Testes]] — RSpec, Factory Bot, cobertura 100%, padrões por camada
- [[04 - Regras de Services]] — service objects, result objects, domínios
- [[05 - Regras de Components]] — Phlex, concerns de view, Turbo Streams
- [[06 - Integração LLM]] — Groq, Gemini, adapters, tool calling, fallback

### Referência
- [[07 - Convenções]] — naming, organização de arquivos, Ruby style, i18n
- [[08 - CI-CD]] — GitHub Actions, Rubocop, cobertura, deploy Kamal
- [[09 - Checklist de Refatoração]] — inconsistências, violações SOLID e code smells encontrados na análise

## Stack Resumida

| Camada | Tecnologia |
|--------|-----------|
| Backend | Ruby 3.3.5, Rails 8.1.2 |
| Banco | PostgreSQL 16 |
| Frontend | Phlex 2.2, Stimulus, Turbo, Tailwind CSS |
| LLM | Groq (llama-3.3-70b) + Gemini (fallback) |
| Testes | RSpec + Factory Bot + SimpleCov (100%) |
| Deploy | Kamal + Docker + Render |

## Comandos do Dia a Dia

```bash
rtk bundle exec rspec                     # suite completa
rtk bundle exec rspec spec/path/arquivo   # spec específica
rtk bundle exec rubocop                   # lint
rtk bundle exec rails db:migrate          # migrações
rtk bundle exec rails tailwindcss:build   # build CSS
```
