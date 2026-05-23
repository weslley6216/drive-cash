
# Design System

## Paleta Semântica

| Cor | Tailwind | Uso | Contexto |
|-----|----------|-----|---------|
| **Emerald** | `emerald-*` | Receita, ganho, positivo | Earnings, profit increase |
| **Red** | `red-*` | Despesa, gasto, alerta | Expenses, losses |
| **Blue** | `blue-*` | Lucro, primário, informação | Hero profit, primary CTA |
| **Yellow** | `yellow-*` | Dias trabalhados | Activity tracking |
| **Purple** | `purple-*` | Rotas, atividade, segmentação | Routes, categories |
| **Violet** | `violet-*` | IA, Caju, assistente | AI features, chat |
| **Amber** | `amber-*` | Insight, aviso, sugestão | Insights, warnings |

### Aplicação Prática

```ruby
# Ganhos (Receita)
bg-emerald-50, border-emerald-200, text-emerald-700, text-emerald-900

# Despesas (Gasto)
bg-red-50, border-red-200, text-red-700, text-red-900

# Lucro (Primário)
bg-blue-50, border-blue-200, text-blue-700, text-blue-900

# Dias
bg-yellow-50, border-yellow-200, text-yellow-700, text-yellow-900

# Rotas
bg-purple-50, border-purple-200, text-purple-700, text-purple-900
```

## Tipografia

| Nível | Tailwind | Peso | Uso |
|-------|----------|------|-----|
| **Display** | `text-4xl` / `text-5xl` | bold (font-bold) | Valores grandes (R$ 16.555,27) |
| **H1** | `text-3xl` | bold | Títulos de tela |
| **H2** | `text-xl` / `text-2xl` | semibold (font-semibold) | Subtítulos, labels de card |
| **Body** | `text-base` / `text-sm` | regular | Texto padrão, descrições |
| **Caption** | `text-xs` | medium (font-medium) | Labels, notas, timestamps |

### Tracking

- Títulos: `tracking-tight` (comprimir)
- Labels normais: sem tracking
- Labels em CAPS: remover (preferir normal case)

## Componentes Visuais

### Cards

Padrão: border + background claro + sombra suave

```ruby
# Padrão de card
div(class: 'border-2 rounded-lg p-4 shadow-sm bg-{color}-50 border-{color}-200')
```

Variantes:
- **Stat Card**: 2×2 grid em mobile, 4 cols em desktop
- **Hero Card**: wider com mini-chart, altura maior
- **Modal**: centered, background translúcido

### Espaçamento

- Padding interno: `p-4`, `p-5`, `p-6`
- Gap entre itens: `gap-2`, `gap-3`, `gap-4`
- Margin entre seções: `mt-4`, `mb-4`
- Radius: `rounded-lg` (cards), `rounded-2xl` (hero)

### Altura/Tamanho

```
h-8 (32px)  — ícones pequenos
h-16 (64px) — charts, componentes médios
h-20 (80px) — charts grandes
w-7 (28px), w-8 (32px) — ícones
```

## Componentes Reutilizáveis

### StatCardComponent

- Título em `text-sm`, subtítulo em `text-xs`
- Valor em `text-xl` (mobile) / `text-2xl` (desktop)
- Ícone em área fixa 32×32px com `flex-shrink-0`
- Cores via prop `:color` (`:green`, `:red`, `:blue`, `:yellow`, `:purple`)

### HeroProfitCardComponent

- Background `bg-blue-50`, border `border-blue-200`
- Valor em `text-3xl bold`
- Mini-chart com 80px altura, gradient fill
- Points marcados com círculos (2.5px branco, 4px azul no último)
- Labels dos meses abaixo (Jan Feb Mar...)

### BottomNavComponent

- Fixo no bottom com `pb-6` (safe area para home indicator)
- 5 abas: Início, Análise, Hoje, Histórico, Mais
- Ativa com `text-blue-700`, inativa com `opacity-60`

### FilterComponent

- Chips de período: Mês, Ano, Período
- Botões secundários com border

## Dark Mode

- Journey screen: `bg-slate-950`, `text-white`
- Componentes: adicionar `:dark` variants conforme necessário
- Logo: versão em branco disponível

## Animações

- **Entrada**: `animate-slide-up` (0.3s)
- **Transição**: `transition-opacity hover:opacity-90`
- **Focus**: `focus:outline-none focus:ring-2 focus:ring-blue-500`

## Breakpoints (Tailwind)

```
mobile: < 640px   (padrão)
sm:    >= 640px
md:    >= 768px   (tablet)
lg:    >= 1024px  (desktop)
xl:    >= 1280px
```

## Relacionado

- [[05 - Regras de Components]]
- [[07 - Convenções]]
