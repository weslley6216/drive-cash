module Ai
  module Tools
    module QueryPerTrip
      def self.declaration
        {
          name:        'query_per_trip',
          description: 'Informa o lucro médio por corrida/entrega no período.',
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
