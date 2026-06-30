module Ai
  module Tools
    module Query
      def self.declaration
        {
          name:        'query',
          description: 'Consulta os dados financeiros e operacionais do motorista. Use o campo type para escolher qual consulta executar.',
          parameters:  {
            type:       'OBJECT',
            properties: {
              type:     {
                type:        'STRING',
                enum:        %w[
                  summary vendor_efficiency best_day worst_platform category_spike
                  margin_drop per_km per_trip tank_balance last_full_tank
                  goal_progress platform_breakdown best_month unpaid_expenses
                  maintenance_status last_maintenance history_search
                ],
                description:
                             'summary=resumo (lucro/ganhos/despesas) · ' \
                  'vendor_efficiency=posto mais econômico (km/L) · ' \
                  'best_day=melhor dia da semana · ' \
                  'worst_platform=plataforma menos lucrativa · ' \
                  'category_spike=categoria de despesa que mais pesou · ' \
                  'margin_drop=queda de margem vs período anterior · ' \
                  'per_km=lucro por km · per_trip=lucro por corrida · ' \
                  'tank_balance=saldo estimado do tanque · ' \
                  'last_full_tank=último abastecimento completo · ' \
                  'goal_progress=progresso das metas · ' \
                  'platform_breakdown=ganhos por plataforma · ' \
                  'best_month=melhor mês de lucro · ' \
                  'unpaid_expenses=despesas em aberto · ' \
                  'maintenance_status=status das manutenções · ' \
                  'last_maintenance=última manutenção (opcional category) · ' \
                  'history_search=busca no histórico (exige term)'
              },
              year:     { type: 'INTEGER', description: 'Ano (padrão: atual)' },
              month:    { type: 'INTEGER', description: 'Mês 1–12 (omitir para o ano todo)' },
              term:     { type: 'STRING', description: 'Termo de busca (usado por history_search)' },
              category: {
                type:        'STRING',
                description: 'Categoria de manutenção (usado por last_maintenance): oil_change, oil_filter, air_filter, fuel_filter, tire_rotation, brake_pads, spark_plugs, timing_belt'
              }
            },
            required:   ['type']
          }
        }
      end
    end
  end
end
