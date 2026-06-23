module Ai
  module Tools
    module QueryBestDay
      def self.declaration
        {
          name:        'query_best_day',
          description: 'Informa qual foi o melhor dia de ganhos do motorista no mês.',
          parameters:  {
            type:       'OBJECT',
            properties: {
              year:  { type: 'INTEGER', description: 'Ano (padrão: atual)' },
              month: { type: 'INTEGER', description: 'Mês 1–12 (padrão: atual)' }
            },
            required:   []
          }
        }
      end
    end
  end
end
