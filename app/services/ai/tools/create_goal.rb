module Ai
  module Tools
    module CreateGoal
      def self.declaration
        {
          name:        'create_goal',
          description: 'Cria uma meta financeira para o motorista.',
          parameters:  {
            type:       'OBJECT',
            properties: {
              kind:          { type: 'STRING', description: 'Período: weekly, monthly, annual' },
              target_amount: { type: 'NUMBER', description: 'Valor alvo em reais' },
              metric:        { type: 'STRING', description: 'Métrica: profit (padrão) ou earnings' }
            },
            required:   ['kind', 'target_amount']
          }
        }
      end
    end
  end
end
